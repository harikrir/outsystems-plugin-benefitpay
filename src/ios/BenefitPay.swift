import Foundation
import BenefitInAppSDK

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var command: CDVInvokedUrlCommand?
    private var button: BPInAppButton?

    override func pluginInitialize() {
        // Register observer for the AppDelegate notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallback(_:)),
            name: NSNotification.Name("BenefitPayCallbackNotification"),
            object: nil
        )
    }

    [span_3](start_span)// SDK Delegate Method[span_3](end_span)
    func bpInAppConfiguration() -> BPInAppConfiguration? {
        return checkoutConfiguration
    }

    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {
        self.command = command

        guard let args = command.arguments, args.count >= 10 else {
            sendError("Missing required payment parameters")
            return
        }

        [span_4](start_span)[span_5](start_span)// 1. Set the CallBackTag (SCHEME ONLY)[span_4](end_span)[span_5](end_span)
        // Do NOT include :// or paths here.
        let callbackTag = "com.aub.mobilebanking.uat.bh"

        [span_6](start_span)// 2. Initialize Configuration[span_6](end_span)
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

        // 3. Trigger the payment flow
        DispatchQueue.main.async {
            self.button = BPInAppButton()
            self.button?.delegate = self
            
            [span_7](start_span)// Access the internal button safely[span_7](end_span)
            if let uiButton = self.button?.subviews.first?.subviews.first as? UIButton {
                uiButton.sendActions(for: .touchUpInside)
            } else {
                self.sendError("Internal SDK Button not found")
            }
        }
    }

    @objc private func handleCallback(_ notification: Notification) {
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
        let errorJson = "{\"status\":\"fail\",\"message\":\"\(message)\"}"
        sendResult(.error, errorJson)
    }

    private func sendResult(_ status: CDVCommandStatus, _ message: String) {
        guard let command = self.command else { return }
        
        let result = CDVPluginResult(status: status, messageAs: message)
        // Set to false to clean up the command after the transaction finishes
        result?.setKeepCallbackAs(false)
        
        self.commandDelegate.send(result, callbackId: command.callbackId)
        self.command = nil 
    }
}
