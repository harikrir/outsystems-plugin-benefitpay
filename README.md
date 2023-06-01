```
# BenefitPay Cordova Plugin

| ![OutSystems Logo](https://media.trustradius.com/product-logos/yQ/pJ/SN525CFRJHL3-180x180.PNG) | A Cordova plugin for integrating the BenefitPay SDK into iOS and Android apps. |
|----------|----------|
| Platform Support | iOS & Android   | 
| License | MIT | 


## Installation

To use this plugin, follow the steps below:

1. Install Cordova:
   ```shell
   npm install -g cordova
   ```

2. Create a new Cordova project:
   ```shell
   cordova create MyApp
   cd MyApp
   ```

3. Add the platform(s) you want to support:
   ```shell
   cordova platform add ios
   cordova platform add android
   ```

4. Install the BenefitPay plugin:
   ```shell
   cordova plugin add https://github.com/andregrillo/outsystems-plugin-benefitpay.git
   ```

5. Configure your app to use the BenefitPay plugin. See the Usage section for details.

## Usage

### iOS

1. Open your Cordova project in Xcode:
   ```shell
   open platforms/ios/MyApp.xcworkspace
   ```

2. In your Cordova app's JavaScript code, call the `checkout` method to initiate the payment process. Pass the required parameters as arguments.

### Android

1. Open your Cordova project in Android Studio.

2. In your Cordova app's JavaScript code, call the `checkout` method to initiate the payment process. Pass the required parameters as arguments.

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
