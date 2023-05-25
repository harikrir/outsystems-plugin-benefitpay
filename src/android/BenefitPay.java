package com.benefitpay;

import static android.app.Activity.RESULT_OK;

import android.content.Intent;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

/*
import mobi.foo.benefitinapp.checkout.BenefitInAppCheckout;
import mobi.foo.benefitinapp.checkout.BenefitInAppListener;
import mobi.foo.benefitinapp.checkout.BenefitInAppResult;
import mobi.foo.benefitinapp.checkout.BenefitInAppButton;
*/

import mobi.foo.benefitinapp.data.Transaction;
import mobi.foo.benefitinapp.utils.BenefitInAppButton;
import mobi.foo.benefitinapp.utils.BenefitInAppCheckout;
import mobi.foo.benefitinapp.listener.CheckoutListener;
import mobi.foo.benefitinapp.listener.BenefitInAppButtonListener;
import mobi.foo.benefitinapp.utils.BenefitInAppHelper;

public class BenefitPay extends CordovaPlugin implements BenefitInAppButtonListener {
    private CallbackContext callbackContext;
    private static final String TAG = "BenefitPayPlugin";

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
                Log.d(TAG, String.format("⭐️ onTransactionSuccess"));
            }

            @Override
            public void onTransactionFail(Transaction transaction) {
                Log.d(TAG, String.format("⭐️ onTransactionFail"));
            }
        };
        benefitInAppCheckout = BenefitInAppCheckout.newInstance(cordova.getActivity(),appId,andReferenceId,andMerchantId,andSecretKey,andAmount,andCountryCode,andCurrencyCode,andMerchantCategoryId,andMerchantName,andMerchantCity,checkoutListener);

    }

    @Override
    public void onFail(int i) {
        Log.d(TAG, String.format("⭐️ onFail"));
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {

        Log.d(TAG, String.format("⭐️ onActivityResult"));

        super.onActivityResult(requestCode, resultCode, intent);

        if (resultCode == RESULT_OK) {
            BenefitInAppHelper.handleResult(intent);
        }
    }
}
