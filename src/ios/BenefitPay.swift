import Foundation
import BenefitInAppSDK

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    private var checkoutConfiguration: BPInAppConfiguration?
    private var command: CDVInvokedUrlCommand?
    private var button: BPInAppButton?

    // MUST match Objective‑C notification name
    private let callbackNotification =
        Notification.Name("BenefitPayCallbackNotification")

    // MARK: - Cordova lifecycle

    override func pluginInitialize() {
        NSLog("✅ [BenefitPay] pluginInitialize CALLED")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallback(_:)),
            name: callbackNotification,
            object: nil
        )

        NSLog("✅ [BenefitPay] Notification observer REGISTERED")

        // ✅ OutSystems / Cordova SAFE:
        // Do NOT cast to AppDelegate (Swift cannot see it).
        // Use Objective‑C runtime (KVC).
        if
            let appDelegate = UIApplication.shared.delegate as? NSObject,
            let item =
                appDelegate.value(forKey: "paymentCallback")
                    as? BPDLPaymentCallBackItem
        {
            NSLog("✅ [BenefitPay] Cached callback FOUND — replaying")

           
let status: String
switch item.status {
case PaymentCallBackStatusSuccess:
    status = "success"
case PaymentCallBackStatusCancel:
    status = "cancelled"
default:
    status = "failed"
}


            let payload: [String: Any] = [
                "status": status,
                "merchantName": item.merchantName ?? "",
                "cardNumber": item.cardNumber ?? "",
                "currency": item.currency ?? "",
                "currencyCode": item.currencyCode ?? "",
                "amount": item.amount ?? "",
                "message": item.message ?? "",
                "referenceId": item.referenceId ?? ""
            ]

            handleCallback(
                Notification(
                    name: callbackNotification,
                    object: nil,
                    userInfo: payload
                )
            )
        } else {
            NSLog("ℹ️ [BenefitPay] No cached callback found")
        }
    }

    // MARK: - Benefit SDK delegate

    func bpInAppConfiguration() -> BPInAppConfiguration? {
        NSLog("✅ [BenefitPay] bpInAppConfiguration requested")
        return checkoutConfiguration
    }

    // MARK: - JS API

    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {

        NSLog("✅ [BenefitPay] checkout() CALLED from JS")
        self.command = command

        guard command.arguments.count == 10 else {
            NSLog("❌ [BenefitPay] Invalid argument count")
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
            NSLog("❌ [BenefitPay] Invalid parameter types")
            sendError("Invalid parameter types")
            return
        }

        // MUST exactly match Info.plist URL scheme
        let callbackTag = "com.aub.mobilebanking.uat.bh"
        NSLog("✅ [BenefitPay] Using callbackTag: \(callbackTag)")

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

        NSLog("✅ [BenefitPay] BPInAppConfiguration CREATED")

        button = BPInAppButton()
        button?.delegate = self

        guard
            let container = button?.subviews.first,
            let uiButton = container.subviews.first as? UIButton
        else {
            NSLog("❌ [BenefitPay] BPInAppButton creation FAILED")
            sendError("Button creation failed")
            return
        }

        NSLog("✅ [BenefitPay] Launching BenefitPay flow")

        DispatchQueue.main.async {
            uiButton.sendActions(for: .touchUpInside)
        }
    }

    // MARK: - Callback handling

    @objc private func handleCallback(_ notification: Notification) {
        NSLog("✅✅ [BenefitPay] handleCallback TRIGGERED")

        guard let payload = notification.userInfo else {
            NSLog("❌ [BenefitPay] Callback payload is NIL")
            sendError("Invalid callback payload")
            return
        }

        NSLog("✅ [BenefitPay] Callback payload: \(payload)")

        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            let json = String(data: data, encoding: .utf8) ?? "{}"

            let status =
                (payload["status"] as? String)?.lowercased() ?? "failed"

            NSLog("✅ [BenefitPay] Final payment status: \(status)")

            sendResult(
                status == "success" ? .ok : .error,
                json
            )
        } catch {
            NSLog("❌ [BenefitPay] JSON serialization FAILED")
            sendError("JSON serialization error")
        }
    }

    // MARK: - JS helpers

    private func sendError(_ message: String) {
        NSLog("❌ [BenefitPay] sendError: \(message)")
        sendResult(
            .error,
            "{\"status\":\"failed\",\"message\":\"\(message)\"}"
        )
    }

 

private func sendResult(
    _ status: CDVCommandStatus,
    _ message: String
) {
    guard let command = command else {
        NSLog("⚠️ [BenefitPay] Command already released")
        return
    }

    NSLog("✅ [BenefitPay] Sending result to JS")

    let result = CDVPluginResult(status: status, messageAs: message)
    result?.setKeepCallbackAs(true)   // 🔥 REQUIRED
    commandDelegate.send(
        result,
        callbackId: command.callbackId
    )
}

    
}
