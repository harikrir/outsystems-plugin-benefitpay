package com.benefitpay;

import static android.app.Activity.RESULT_OK;

import android.content.Intent;
import org.json.JSONObject;
import org.json.JSONException;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import mobi.foo.benefitinapp.data.Transaction;
import mobi.foo.benefitinapp.utils.BenefitInAppButton;
import mobi.foo.benefitinapp.utils.BenefitInAppCheckout;
import mobi.foo.benefitinapp.listener.CheckoutListener;
import mobi.foo.benefitinapp.listener.BenefitInAppButtonListener;
import mobi.foo.benefitinapp.utils.BenefitInAppHelper;

import java.util.Random;

public class BenefitPay extends CordovaPlugin implements BenefitInAppButtonListener {
    private CallbackContext callbackContext;
    private static final String TAG = "BenefitPayPlugin";

    private Transaction transactionResult;

    String appId;
    String andSecretKey;
    String andAmount;
    String andCurrencyCode;
    String andMerchantId;
    String andMerchantName;
    String andMerchantCity;
    String andCountryCode;
    String andMerchantCategoryId;
    String andReferenceId;
    CheckoutListener checkoutListener;
    BenefitInAppCheckout benefitInAppCheckout;

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if ("checkout".equals(action)) {
            appId = args.getString(0);
            andSecretKey = args.getString(1);
            andAmount = args.getString(2);
            andCurrencyCode = args.getString(3);
            andMerchantId = args.getString(4);
            andMerchantName = args.getString(5);
            andMerchantCity = args.getString(6);
            andCountryCode = args.getString(7);
            andMerchantCategoryId = args.getString(8);
            andReferenceId = args.getString(9);

            BenefitInAppButton checkoutButton = new BenefitInAppButton(this.cordova.getContext());
            checkoutButton.setListener(this);
            checkoutButton.performClick();
            return true;
        }
        return false;
    }

    @Override
    public void onButtonClicked() {
        checkoutListener = new CheckoutListener() {
            @Override
            public void onTransactionSuccess(Transaction transaction) {

                String merchantName = (transaction.getMerchant() == null || transaction.getMerchant().isEmpty()) ? "" : transaction.getMerchant();
                String cardNumber = (transaction.getCardNumber() == null || transaction.getCardNumber().isEmpty()) ? "" : transaction.getCardNumber();
                String currency = (transaction.getCurrency() == null || transaction.getCurrency().isEmpty()) ? "" : transaction.getCurrency();
                String currencyCode = "";
                String amount = (transaction.getAmount() == null || transaction.getAmount().isEmpty()) ? "" : transaction.getAmount();
                String message = (transaction.getTransactionMessage() == null || transaction.getTransactionMessage().isEmpty()) ? "" : transaction.getTransactionMessage();
                String referenceId = (transaction.getReferenceNumber() == null || transaction.getReferenceNumber().isEmpty()) ? "" : transaction.getReferenceNumber();

                JSONObject json = new JSONObject();
                try {
                    json.put("status", "success");
                    json.put("merchantName", merchantName);
                    json.put("cardNumber", cardNumber);
                    json.put("currency", currency);
                    json.put("currencyCode", currencyCode);
                    json.put("amount", amount);
                    json.put("message", message);
                    json.put("referenceId", referenceId);

                    String jsonString = json.toString();
                    callbackContext.success(jsonString);

                } catch (JSONException e) {
                    e.printStackTrace();
                    callbackContext.error("Error: Could not create JSON object. Invalid types received from SDK?");
                }
            }

            @Override
            public void onTransactionFail(Transaction transaction) {

                String merchantName = (transaction.getMerchant() == null || transaction.getMerchant().isEmpty()) ? "" : transaction.getMerchant();
                String cardNumber = (transaction.getCardNumber() == null || transaction.getCardNumber().isEmpty()) ? "" : transaction.getCardNumber();
                String currency = (transaction.getCurrency() == null || transaction.getCurrency().isEmpty()) ? "" : transaction.getCurrency();
                String currencyCode = "";
                String amount = (transaction.getAmount() == null || transaction.getAmount().isEmpty()) ? "" : transaction.getAmount();
                String message = (transaction.getTransactionMessage() == null || transaction.getTransactionMessage().isEmpty()) ? "" : transaction.getTransactionMessage();
                String referenceId = (transaction.getReferenceNumber() == null || transaction.getReferenceNumber().isEmpty()) ? "" : transaction.getReferenceNumber();

                JSONObject json = new JSONObject();
                try {
                    json.put("status", "failed");
                    json.put("merchantName", merchantName);
                    json.put("cardNumber", cardNumber);
                    json.put("currency", currency);
                    json.put("currencyCode", currencyCode);
                    json.put("amount", amount);
                    json.put("message", message);
                    json.put("referenceId", referenceId);

                    String jsonString = json.toString();
                    callbackContext.error(jsonString);

                } catch (JSONException e) {
                    e.printStackTrace();
                    callbackContext.error("Error: Could not create JSON object. Invalid types received from SDK?");
                }
            }
        };
        cordova.setActivityResultCallback(this);
        benefitInAppCheckout = BenefitInAppCheckout.newInstance(cordova.getActivity(),appId,andReferenceId,andMerchantId,andSecretKey,andAmount,andCountryCode,andCurrencyCode,andMerchantCategoryId,andMerchantName,andMerchantCity,checkoutListener);

    }

    @Override
    public void onFail(int i) {
        callbackContext.error("Error: Could not complete transaction request. Are Inputs parameters valid?");
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {

        super.onActivityResult(requestCode, resultCode, intent);

        if (resultCode == RESULT_OK) {
            BenefitInAppHelper.handleResult(intent);
        } else {
            BenefitInAppHelper.handleResult(intent);
            if (resultCode == 0) {
                JSONObject json = new JSONObject();
                try {
                    json.put("status", "cancelled");
                    json.put("merchantName", this.andMerchantName);
                    json.put("cardNumber", " ");
                    json.put("currency", " ");
                    json.put("currencyCode", this.andCurrencyCode);
                    json.put("amount", this.andAmount);
                    json.put("message", " ");
                    json.put("referenceId", this.andReferenceId);

                    String jsonString = json.toString();
                    callbackContext.error(jsonString);

                } catch (JSONException e) {
                    e.printStackTrace();
                    callbackContext.error("Error: Could not create JSON object. Invalid types received from SDK?");
                }
            }
        }
    }

    public String generateRandomNumber() {
        Random random = new Random();
        int number = random.nextInt(900000) + 100000;
        return String.valueOf(number);
    }

}
