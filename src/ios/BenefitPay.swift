import Foundation
import BenefitInAppSDK
import NotificationCenter

// MUST match Constants.m exactly
public let kNotification =
    Notification.Name("CallbackNotification")

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var command: CDVInvokedUrlCommand?
    private var bpButton: BPInAppButton?

    // SDK config provider
    func bpInAppConfiguration() -> BPInAppConfiguration? {
        return checkoutConfiguration
    }

    // Cordova entry
    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {

        self.command = command

        guard command.arguments.count == 10 else {
            sendError("Expected 10 parameters")
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
            sendError("Invalid argument types")
            return
        }

        let callbackTag = "com.aub.mobilebanking.uat.bh"

        // Observe AppDelegate callback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallback(_:)),
            name: kNotification,
            object: nil
        )

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

        bpButton = BPInAppButton()
        bpButton?.delegate = self

        // IMPORTANT: keep callback alive
      //  sendSuccess("{\"status\":\"initiated\"}", keep: true)
         // ✅ IMPORTANT FIX:
        // Do NOT send success or error now.
        // Tell Cordova: "I will respond later"
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus.noResult
        )
        pluginResult?.keepCallback = NSNumber(value: true)

        if let callbackId = command.callbackId {
            commandDelegate.send(pluginResult, callbackId: callbackId)
        }

        DispatchQueue.main.async {
            guard
                let button =
                    self.bpButton?
                        .subviews.first?
                        .subviews.first as? UIButton
            else { return }

            button.sendActions(for: .touchUpInside)
        }
    }

    // Receive callback from AppDelegate
    @objc func handleCallback(_ notification: Notification) {

        NotificationCenter.default.removeObserver(
            self,
            name: kNotification,
            object: nil
        )

        guard let info = notification.userInfo else {
            sendError("Empty callback")
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: info)
            let json = String(data: data, encoding: .utf8) ?? "{}"

            if info["status"] as? String == "success" {
                sendSuccess(json)
            } else {
                sendError(json, raw: true)
            }
        } catch {
            sendError("Failed to parse callback")
        }
    }

    // Helpers
    private func sendSuccess(_ msg: String, keep: Bool = false) {
        send(.ok, msg, keep)
    }

    private func sendError(_ msg: String, raw: Bool = false) {
        let payload = raw
            ? msg
            : "{\"status\":\"failed\",\"message\":\"\(msg)\"}"
        send(.error, payload, false)
    }

    private func send(
        _ status: CDVCommandStatus,
        _ message: String,
        _ keep: Bool
    ) {
        let result = CDVPluginResult(status: status, messageAs: message)
       result?.keepCallback = NSNumber(value: keep)
        if let callbackId = command?.callbackId {
            commandDelegate.send(result, callbackId: callbackId)
        }
    }
}
