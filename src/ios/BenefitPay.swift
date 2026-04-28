import Foundation
import BenefitInAppSDK

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var command: CDVInvokedUrlCommand?
    private var button: BPInAppButton?
    private let notificationName = NSNotification.Name("BenefitPayCallbackNotification")

    // MARK: - SDK Delegate Method
    @objc func bpInAppConfiguration() -> BPInAppConfiguration? {
        return checkoutConfiguration
    }

    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {
        self.command = command

        guard let args = command.arguments, args.count >= 10 else {
            sendError("Missing required payment parameters")
            return
        }

        // 1. Clean up any existing observer before starting a new session
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)

        // 2. Add observer specifically for this checkout session
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallback(_:)),
            name: notificationName,
            object: nil
        )

        let callbackTag = "com.aub.mobilebanking.uat.bh"

        // 3. Initialize Configuration
        checkoutConfiguration = BPInAppConfiguration(
            appId: args[0] as? String ?? "",
            andSecretKey: args[1] as? String ?? "",
            andAmount: args[2] as? String ?? "",
            andCurrencyCode: args[3] as? String ?? "",
            andMerchantId: args[4] as? String ?? "",
            andMerchantName: args[5] as? String ?? "",
            andMerchantCity: args[6] as? String ?? "",
            andCountryCode: args[7] as? String ?? "",
            andMerchantCategoryId: args[8] as? String ?? "",
            andReferenceId: args[9] as? String ?? "",
            andCallBackTag: callbackTag
        )

        // 4. Trigger the payment flow
        DispatchQueue.main.async {
            self.button = BPInAppButton()
            self.button?.delegate = self
            
            if let uiButton = self.button?.subviews.first?.subviews.first as? UIButton {
                uiButton.sendActions(for: .touchUpInside)
            } else {
                self.sendError("Internal SDK Button not found")
            }
        }
    }

    @objc private func handleCallback(_ notification: Notification) {
        // Stop listening once we receive a result
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)

        guard let payload = notification.userInfo else { return }

        let status = (payload["status"] as? String) ?? "fail"
        let resultStatus: CDVCommandStatus = (status == "success") ? .ok : .error

        do {
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            let jsonString = String(data: data, encoding: .utf8) ?? "{}"
            self.sendResult(resultStatus, jsonString)
        } catch {
            self.sendError("Callback data processing failed")
        }
    }

    private func sendError(_ message: String) {
        // Also remove observer on immediate errors
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        let errorJson = "{\"status\":\"fail\",\"message\":\"\(message)\"}"
        sendResult(.error, errorJson)
    }

    private func sendResult(_ status: CDVCommandStatus, _ message: String) {
        guard let command = self.command else { return }
        let result = CDVPluginResult(status: status, messageAs: message)
        result?.setKeepCallbackAs(false)
        self.commandDelegate.send(result, callbackId: command.callbackId)
        self.command = nil 
    }
}
