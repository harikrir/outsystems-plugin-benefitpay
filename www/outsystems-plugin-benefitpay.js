var exec = require('cordova/exec');

exports.checkout = function (success, error, appId, secretKey, amount, currencyCode, merchantId, merchantName, merchantCity, countryCode, merchantCategoryId, referenceId) {
    exec(
        success, 
        error, 
        'BenefitPay', 
        'checkout', 
        [
            appId, 
            secretKey, 
            amount, 
            currencyCode, 
            merchantId, 
            merchantName, 
            merchantCity, 
            countryCode, 
            merchantCategoryId, 
            referenceId
        ]
    );
};
