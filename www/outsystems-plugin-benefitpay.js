var exec = require('cordova/exec');




var BenefitPay = {
    checkout: function (success, error, arg0) {
        exec(success, error, 'BenefitPay', 'checkout', arg0);
    }
}


    module.exports = BenefitPay;
