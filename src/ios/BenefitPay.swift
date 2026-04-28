import Foundation
import BenefitInAppSDK

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var command: CDVInvokedUrlCommand?
    private var button: BPInAppButton?

    override func pluginInitialize() {
        NSLog("🔥🔥🔥 BenefitPay pluginInitialize")
        print("🔥 PRINT pluginInitialize")
        fprintf(stderr, "🔥 STDERR pluginInitialize\n")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallback(_:)),
            name: Notification.Name("BenefitPayCallbackNotification"),
            object: nil
        )
    }

    func bpInAppConfiguration() -> BPInAppConfiguration? {
        NSLog("✅ bpInAppConfiguration requested")
        return checkoutConfiguration
    }

    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {

        NSLog("🔥🔥🔥 checkout CALLED")
        self.command = command

        guard command.arguments.count == 10 else {
            sendError("Invalid argument count")
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

        let callbackTag =
            "com.aub.mobilebanking.uat.bh://MobileBanking_Bahrain/FundMyAccount"

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

    @objc private func handleCallback(_ notification: Notification) {
        NSLog("✅✅✅ CALLBACK RECEIVED")

        guard let payload = notification.userInfo else {
            sendError("Callback payload missing")
            return
        }

        let status =
            (payload["status"] as? String)?.lowercased() ?? "fail"

        let resultStatus: CDVCommandStatus =
            status == "fail" ? .error : .ok

        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            let json = String(data: data, encoding: .utf8) ?? "{}"

            sendResult(resultStatus, json)
        } catch {
            sendError("JSON serialization failed")
        }
    }

    private func sendError(_ message: String) {
        sendResult(
            .error,
            "{\"status\":\"fail\",\"message\":\"\(message)\"}"
        )
    }

    private func sendResult(
        _ status: CDVCommandStatus,
        _ message: String
    ) {
        guard let command = command else { return }

        let result = CDVPluginResult(
            status: status,
            messageAs: message
        )
        result?.setKeepCallbackAs(true)
        commandDelegate.send(
            result,
            callbackId: command.callbackId
        )
    }
}
