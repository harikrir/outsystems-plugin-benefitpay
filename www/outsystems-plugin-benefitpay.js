var exec = require('cordova/exec');

exports.checkout = function (success, error, arg0) {
    exec(success, error, 'BenefitPay', 'checkout', arg0);
};
