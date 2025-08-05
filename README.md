# BenefitPay Cordova Plugin

| A Cordova plugin for integrating the BenefitPay SDK into iOS and Android apps. |
|----------|----------|
| Platform Support | iOS & Android   | 
| License | MIT | 


## Installation

Install the BenefitPay plugin:
   ```shell
   cordova plugin add https://github.com/harikrir/outsystems-plugin-benefitpay.git
   ```

## Usage

### iOS & Android

- In your Cordova app's JavaScript code, call the `checkout` method to initiate the payment process. Pass the required parameters as arguments.

## API Reference

### Methods

#### checkout

```javascript
cordova.plugins.BenefitPay.checkout(appId, secretKey, amount, currencyCode, merchantId, merchantName, merchantCity, countryCode, merchantCategoryId, referenceId, successCallback, errorCallback)
```

Initiates the payment process using the BenefitPay SDK.

- `appId` (string): The BenefitPay app ID.
- `secretKey` (string): The secret key for the BenefitPay app.
- `amount` (string): The payment amount.
- `currencyCode` (string): The currency code for the payment.
- `merchantId` (string): The merchant ID.
- `merchantName` (string): The name of the merchant.
- `merchantCity` (string): The city of the merchant.
- `countryCode` (string): The country code of the merchant.
- `merchantCategoryId` (string): The category ID of the merchant.
- `referenceId` (string): The reference ID for the payment.
- `successCallback` (function): The callback function to handle successful payment.
- `errorCallback` (function): The callback function to handle payment errors.

## License

This plugin is released under the [MIT License](LICENSE).
```
