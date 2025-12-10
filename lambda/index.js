// https://docs.wafcharm.com/manual/new_aws_waf/index.js
"use strict";

const toBucket = process.env.WAFCHARM_BUCKET || "wafcharm.com";
const toRegion = process.env.WAFCHARM_REGION || "ap-northeast-1";
const wafVersion = process.env.WAF_VERSION || "v2";
const acl = "bucket-owner-full-control";

let isModuleLoaded = false;
let useModuleV3 = false;

// AWS SDK for JavaScript V2 (Runtime Node.js <= 16.x)
let AWS = null;
let s3 = null;

// AWS SDK for JavaScript V3 (Runtime Node.js >= 18.x)
let s3ClientModule = null;
let libStorageModule = null;
let srcS3Client = null;
let destS3Client = null;

loadModules();

function loadModules() {
  if (isModuleLoaded) {
    console.log("Already loaded module SDK " + (useModuleV3 ? "V3" : "V2"));
    return;
  }

  try {
    // Try to load module AWS SDK for JavaScript V3
    s3ClientModule = require("@aws-sdk/client-s3");
    libStorageModule = require("@aws-sdk/lib-storage");
    srcS3Client = new s3ClientModule.S3Client();
    destS3Client = new s3ClientModule.S3Client({ region: toRegion });
    console.log("Success to load module SDK V3");
    isModuleLoaded = true;
    useModuleV3 = true;
  } catch (e) {
    // Try to load module AWS SDK for JavaScript V2
    AWS = require("aws-sdk");
    s3 = new AWS.S3({
      apiVersion: "2006-03-01",
    });
    console.log("Success to load module SDK V2");
    isModuleLoaded = true;
    useModuleV3 = false;
  }
}

function destinationPath(version) {
  const v = version || wafVersion;
  return `waflog/acceptance/${v}`;
}

function getDestKeyWhenMatched(str, ptn, callback) {
  let match = str.match(ptn);
  if (!match) {
    return false;
  }
  return callback(match);
}

function sendV2(toParams, retryNum) {
  if (retryNum === 0) {
    return;
  }
  s3.putObject(toParams, (err, data) => {
    if (err) {
      console.error("Cannot put object.");
      console.error(err);
      sendV2(toParams, retryNum - 1);
    } else {
      return;
    }
  });
}

function copyV2(fromParams, destObjectKey) {
  s3.getObject(fromParams, (err, data) => {
    if (err) {
      console.error("Cannot get object.");
      console.error(err);
      return;
    }
    const toParams = {
      Bucket: toBucket,
      Key: destObjectKey,
      ACL: acl,
      Body: data.Body,
    };
    sendV2(toParams, 3);
  });
}

async function sendV3(toParams, retryNum) {
  if (retryNum === 0) {
    return;
  }

  try {
    const upload = new libStorageModule.Upload({
      client: destS3Client,
      params: toParams,
    });
    await upload.done();
  } catch (e) {
    console.error("Cannot put object.");
    console.error(e);
    await sendV3(toParams, retryNum - 1);
  }
  return;
}

async function copyV3(fromParams, destObjectKey) {
  let toParams = null;
  try {
    const getObjectOutput = await srcS3Client.send(
      new s3ClientModule.GetObjectCommand(fromParams),
    );
    toParams = {
      Bucket: toBucket,
      Key: destObjectKey,
      ACL: acl,
      Body: getObjectOutput.Body,
    };
  } catch (e) {
    console.error("Cannot get object.");
    console.error(e);
    return;
  }
  await sendV3(toParams, 3);
}

exports.handler = (event) => {
  const s3BucketName = event.Records[0].s3.bucket.name;
  const s3ObjectKey = decodeURIComponent(event.Records[0].s3.object.key);

  // false or string
  let destObjectKey = false;
  if (!destObjectKey) {
    // via KDF
    const toPath = destinationPath();
    destObjectKey = getDestKeyWhenMatched(
      s3ObjectKey,
      /\d{4}\/\d{2}\/\d{2}\/\d{2}\/[^\/]*$/,
      (match) => {
        return [toPath, match[0]].join("/");
      },
    );
  }
  if (!destObjectKey) {
    // via S3 direct (v2 only)
    const toPath = destinationPath("v2");
    destObjectKey = getDestKeyWhenMatched(
      s3ObjectKey,
      /(\d{4}\/\d{2}\/\d{2}\/\d{2})\/\d{2}\/([^\/]*$)/,
      (match) => {
        return [toPath, match[1], match[2]].join("/");
      },
    );
  }
  if (!destObjectKey) {
    // via KDF (hive format)
    const toPath = destinationPath();
    destObjectKey = getDestKeyWhenMatched(
      s3ObjectKey,
      /year=(\d{4})\/month=(\d{2})\/day=(\d{2})\/hour=(\d{2}\/[^\/]*$)/,
      (match) => {
        return [toPath, match[1], match[2], match[3], match[4]].join("/");
      },
    );
  }
  if (!destObjectKey) {
    console.error("Not match the AWS WAF full log event. : ", s3ObjectKey);
    return;
  }

  const fromParams = {
    Bucket: s3BucketName,
    Key: s3ObjectKey,
  };

  // copy
  const copy = useModuleV3 ? copyV3 : copyV2;
  copy(fromParams, destObjectKey);
};
