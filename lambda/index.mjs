// https://docs.wafcharm.com/manual/new_aws_waf/v2/index.mjs
import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { Upload } from "@aws-sdk/lib-storage";

const destBucket = process.env.WAFCHARM_BUCKET || "wafcharm.com";
const destRegion = process.env.WAFCHARM_REGION || "ap-northeast-1";
const wafVersion = process.env.WAF_VERSION || "v2";
const acl = "bucket-owner-full-control";

function getDestObjectKey(srcObjectKey) {
  const destPath = (version) => `waflog/acceptance/${version || wafVersion}`;

  const getKey = (pattern, callback) => {
    const match = srcObjectKey.match(pattern);
    return match ? callback(match) : "";
  };

  return (
    // via KDF
    getKey(/\d{4}\/\d{2}\/\d{2}\/\d{2}\/[^\/]*$/, (match) =>
      [destPath(), match[0]].join("/"),
    ) ||
    // via S3 direct (v2 only)
    getKey(/(\d{4}\/\d{2}\/\d{2}\/\d{2})\/\d{2}\/([^\/]*$)/, (match) =>
      [destPath("v2"), match[1], match[2]].join("/"),
    ) ||
    // via KDF (hive format)
    getKey(
      /year=(\d{4})\/month=(\d{2})\/day=(\d{2})\/hour=(\d{2}\/[^\/]*$)/,
      (match) => [destPath(), match[1], match[2], match[3], match[4]].join("/"),
    )
  );
}

async function transport(srcParams, destObjectKey) {
  const command = new GetObjectCommand(srcParams);
  const downloadClient = new S3Client();
  const response = await downloadClient.send(command);

  const uploadClient = new S3Client({ region: destRegion });
  const upload = new Upload({
    client: uploadClient,
    params: {
      Bucket: destBucket,
      Key: destObjectKey,
      ACL: acl,
      Body: response.Body,
    },
  });

  await upload.done();
}

export async function handler(event) {
  const srcObjectKey = decodeURIComponent(event.Records[0].s3.object.key);
  const destObjectKey = getDestObjectKey(srcObjectKey);
  if (!destObjectKey) {
    console.error(
      "Not match the AWS WAF full log event. : ",
      JSON.stringify(srcObjectKey),
    );
    return;
  }

  const srcParams = {
    Bucket: event.Records[0].s3.bucket.name,
    Key: srcObjectKey,
  };

  await transport(srcParams, destObjectKey);
  console.log("Transport completed.");
}
