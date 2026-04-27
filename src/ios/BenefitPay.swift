//
//  BenefitPay.swift
//

import FoundationAppSDKimport Foundation
import NotificationCenter

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var lastCommand: CDVInvokedUrlCommand?
    private var bPButton: BPInAppButton?

    // ✅ MUST match Objective-C notification value exactly
    private let notificationName =
        Notification.Name("CallbackNotification")

    // ✅ OutSystems-safe logger
    private func log(_ message: String) {
        NSLog("[BenefitPay] %@", message)
    }

    // ✅ Called once when plugin is loaded
    override func pluginInitialize() {
        super.pluginInitialize()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallBack(_:)),
            name: notificationName,
            object: nil
        )

        log("Plugin initialized and observer registered")
    }

    // ✅ SDK configuration provider
    func bpInAppConfiguration() -> BPInAppConfiguration? {
        checkoutConfiguration
    }

    // ✅ Cordova entry point
    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {

        self.lastCommand = command
        log("Checkout initiated")

        guard command.arguments.count == 10 else {
            let msg =
              "{\"status\":\"failed\",\"message\":\"Expected 10 arguments, got \(command.arguments.count)\"}"
            sendPluginResult(status: .error, message: msg)
            return
        }

        guard
            let appId = command.arguments[0] as? String,
            let secretKey = command.arguments[1] as? String,
            let amount = command.arguments[2] as? String,
            let currencyCode = command.arguments[3] as? String,
            let merchantId = command.arguments[4] as? String,
            let merchantName = command.arguments[5] as? String,
            let merchantCity = command.arguments[6] as? String,
            let countryCode = command.arguments[7] as? String,
            let mcc = command.arguments[8] as? String,
            let referenceId = command.arguments[9] as? String
        else {
            sendPluginResult(
                status: .error,
                message: "{\"status\":\"failed\",\"message\":\"Invalid argument types\"}"
            )
            return
        }

        let callbackTag =
            "com.aub.mobilebanking.uat.bh".lowercased()

        checkoutConfiguration = BPInAppConfiguration(
            appId: appId,
            andSecretKey: secretKey,
            andAmount: amount,
            andCurrencyCode: currencyCode,
            andMerchantId: merchantId,
            andMerchantName: merchantName,
            andMerchantCity: merchantCity,
            andCountryCode: countryCode,
            andMerchantCategoryId: mcc,
            andReferenceId: referenceId,
            andCallBackTag: callbackTag
        )

        log("Configuration set for reference: \(referenceId)")

        bPButton = BPInAppButton()
        bPButton?.delegate = self

        // ✅ Trigger SDK safely
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard
                let container = self.bPButton?.subviews.first,
                let button = container.subviews.first as? UIButton
            else {
                self.log("Failed to locate internal SDK button")
                return
            }

            self.log("Triggering BenefitPay button")
            button.sendActions(for: .touchUpInside)
        }
    }

    // ✅ Receive deep-link callback from AppDelegate
    @objc func handleCallBack(_ notification: Notification) {

        log("Callback notification received")

        guard let info = notification.userInfo else {
            sendPluginResult(
                status: .error,
                message: "{\"status\":\"failed\",\"message\":\"Empty callback\"}"
            )
            return
        }

        do {
            let data =
                try JSONSerialization.data(withJSONObject: info)
            let json =
                String(data: data, encoding: .utf8) ?? "{}"

            let status =
                info["status"] as? String ?? "failed"

            sendPluginResult(
                status: status == "success" ? .ok : .error,
                message: json
            )

        } catch {
            sendPluginResult(
                status: .error,
                message: "{\"status\":\"failed\",\"message\":\"JSON serialization error\"}"
            )
        }
    }

    // ✅ Send Cordova result
    private func sendPluginResult(
        status: CDVCommandStatus,
        message: String
    ) {
        guard let command = lastCommand else {
            log("No pending Cordova command")
            return
        }

        let result =
            CDVPluginResult(status: status, messageAs: message)

        commandDelegate?.send(
            result,
            callbackId: command.callbackId
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        log("Observer removed")
    }
}
``
