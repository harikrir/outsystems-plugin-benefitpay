import Foundation
import BenefitInAppSDK

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var command: CDVInvokedUrlCommand?
    private var button: BPInAppButton?

    private let callbackNotification =
        Notification.Name("BenefitPayCallbackNotification")

    // ✅ Called once when plugin loads
    override func pluginInitialize() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallback(_:)),
            name: callbackNotification,
            object: nil
        )
    }

    // ✅ Required by Benefit SDK
    func bpInAppConfiguration() -> BPInAppConfiguration? {
        return checkoutConfiguration
    }

    // ✅ Called from JS
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
            let merchantCategoryId = command.arguments[8] as? String,
            let referenceId = command.arguments[9] as? String
        else {
            sendError("Invalid parameter types")
            return
        }

        // ✅ MUST MATCH Info.plist URL Scheme
        let callbackTag = "com.aub.mobilebanking.uat.bh"

        checkoutConfiguration = BPInAppConfiguration(
            appId: appId,
            andSecretKey: secretKey,
            andAmount: amount,
            andCurrencyCode: currencyCode,
            andMerchantId: merchantId,
            andMerchantName: merchantName,
            andMerchantCity: merchantCity,
            andCountryCode: countryCode,
            andMerchantCategoryId: merchantCategoryId,
            andReferenceId: referenceId,
            andCallBackTag: callbackTag
        )

        button = BPInAppButton()
        button?.delegate = self

        guard
            let container = button?.subviews.first,
            let uiButton = container.subviews.first as? UIButton
        else {
            sendError("Button creation failed")
            return
        }

        DispatchQueue.main.async {
            uiButton.sendActions(for: .touchUpInside)
        }
    }

    // ✅ Receive callback from AppDelegate
    @objc private func handleCallback(_ notification: Notification) {

        guard let payload = notification.userInfo else {
            sendError("Invalid callback payload")
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            let json = String(data: data, encoding: .utf8) ?? "{}"

            let status =
              (payload["status"] as? String)?.lowercased() ?? "failed"

            if status == "success" {
                sendResult(.OK, json)
            } else {
                sendResult(.ERROR, json)
            }

        } catch {
            sendError("JSON serialization error")
        }
    }

    private func sendError(_ message: String) {
        let payload = """
        {"status":"failed","message":"\(message)"}
        """
        sendResult(.ERROR, payload)
    }

    private func sendResult(_ status: CDVCommandStatus, _ message: String) {
        guard let command = command else { return }
        let result = CDVPluginResult(status: status, messageAs: message)
        commandDelegate.send(result, callbackId: command.callbackId)
    }
}

