var fs = require("fs");
var path = require("path");
var et = require('elementtree');

function saveFile(filePath, fileContents) {
  return new Promise((resolve, reject) => {
    fs.writeFile(filePath, fileContents, 'utf8', function (err) {
      if (err) {
        reject(new Error('🚨 Unable to write into ' + filePath + ': \n' + err));
      } else {
        console.log("✅ " + filePath + " saved successfully");
        resolve();
      }
    });
  });
}

function replace_callBackTag(filePath, placeholder, callbackTag) {
  return new Promise((resolve, reject) => {
    fs.readFile(filePath, 'utf8', function (err, fileData) {
      if (err) {
        reject(new Error('🚨 Unable to read ' + filePath + " :" + err));
      } else {
        if (fileData.includes(placeholder)) {
          var fileContents = fileData.replace(new RegExp(placeholder, 'g'), callbackTag);
          saveFile(filePath, fileContents)
            .then(resolve)
            .catch(reject);
        } else {
          console.log("⚠️ Warning: file " + filePath + " does not contain: " + placeholder);
          resolve();
        }
      }
    });
  });
}

module.exports = function (context) {

  const args = process.argv

  var callbackTag;
  for (const arg of args) {
    if (arg.includes('callbackTag')) {
      var stringArray = arg.split("=");
      callbackTag = stringArray.slice(-1).pop();
    }
  }

  if (callbackTag === null || callbackTag === "") {
    console.log("🚨 callbackTag cannot be null or an empty string");
    throw new Error("🚨 callbackTag cannot be null or an empty string");
  }

  const placeholder = "callbackTag_placeholder";
  var filePath = path.join(context.opts.projectRoot, '/plugins/outsystems-plugin-benefitpay/src/ios/BenefitPay.swift');

  return replace_callBackTag(filePath, placeholder, callbackTag);
};
