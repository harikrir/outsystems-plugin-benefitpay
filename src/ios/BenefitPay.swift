//
//  BenefitPay.swift
//
//  Created by Andre Grillo on 17/05/2023.
//

import Foundation
import BenefitInAppSDK
import NotificationCenter

public let kNotification = Notification.Name("kCallbackNotification")

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {

    var checkoutConfiguration: BPInAppConfiguration?
    var command: CDVInvokedUrlCommand?
    var bPButton: BPInAppButton?

    func bpInAppConfiguration() -> BPInAppConfiguration? {
        return checkoutConfiguration
    }

    // ✅ FIX 1: Move observer OUT of checkout (avoid duplicate + missed callbacks)
    override func pluginInitialize() {
        super.pluginInitialize()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCallBack(_:)),
            name: kNotification,
            object: nil
        )
    }

    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand) {

        self.command = command
        print("Checking out...")

        if command.arguments.count == 10 {

            if let appId = command.arguments[0] as? String,
               let andSecretKey = command.arguments[1] as? String,
               let andAmount = command.arguments[2] as? String,
               let andCurrencyCode = command.arguments[3] as? String,
               let andMerchantId = command.arguments[4] as? String,
               let andMerchantName = command.arguments[5] as? String,
               let andMerchantCity = command.arguments[6] as? String,
               let andCountryCode = command.arguments[7] as? String,
               let andMerchantCategoryId = command.arguments[8] as? String,
               let andReferenceId = command.arguments[9] as? String {

                let andCallBackTag = "com.aub.mobilebanking.uat.bh".lowercased()

                self.checkoutConfiguration = BPInAppConfiguration(
                    appId: appId,
                    andSecretKey: andSecretKey,
                    andAmount: andAmount,
                    andCurrencyCode: andCurrencyCode,
                    andMerchantId: andMerchantId,
                    andMerchantName: andMerchantName,
                    andMerchantCity: andMerchantCity,
                    andCountryCode: andCountryCode,
                    andMerchantCategoryId: andMerchantCategoryId,
                    andReferenceId: andReferenceId,
                    andCallBackTag: andCallBackTag
                )

                self.bPButton = BPInAppButton()
                self.bPButton!.delegate = self

                guard let innerView = bPButton!.subviews.first,
                      let button = innerView.subviews.first as? UIButton else {
                    print("❌ Button creation failed")
                    return
                }

                // ✅ FIX 2: safer event trigger
                DispatchQueue.main.async {
                    button.sendActions(for: .touchUpInside)
                }

            } else {
                let message = "{\"status\": \"failed\", \"message\": \"Invalid input types\"}"
                sendPluginResult(status: CDVCommandStatus_ERROR, message: message)
            }

        } else {
            let message = "{\"status\": \"failed\", \"message\": \"Expected 10 parameters\"}"
            sendPluginResult(status: CDVCommandStatus_ERROR, message: message)
        }
    }

    // MARK: - Callback handler
    @objc func handleCallBack(_ notification: Notification) {

        print("📩 Callback received")

        guard let callbackInfo = notification.userInfo as? [String: Any] else {
            let message = "{\"status\": \"failed\", \"message\": \"Invalid callback object\"}"
            sendPluginResult(status: CDVCommandStatus_ERROR, message: message)
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: callbackInfo, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            print("✅ Callback JSON: \(jsonString)")

            DispatchQueue.main.async {

                if let status = callbackInfo["status"] as? String,
                   status.lowercased() == "success" {

                    self.sendPluginResult(
                        status: CDVCommandStatus_OK,
                        message: jsonString
                    )

                } else {

                    self.sendPluginResult(
                        status: CDVCommandStatus_ERROR,
                        message: jsonString
                    )
                }
            }

        } catch {
            let message = "{\"status\": \"failed\", \"message\": \"JSON conversion error\"}"
            sendPluginResult(status: CDVCommandStatus_ERROR, message: message)
        }
    }

    // MARK: - FIX 3: remove force unwrap crash risk
    func sendPluginResult(status: CDVCommandStatus,
                          message: String,
                          keepCallback: Bool = false) {

        guard let command = self.command else {
            print("❌ No command available")
            return
        }

        let pluginResult = CDVPluginResult(status: status, messageAs: message)
         if keepCallback {
        pluginResult?.setKeepCallbackAs(true)
    }

        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }

    func generateRandomNumber() -> Int {
        return Int.random(in: 100_000...999_999)
    }
}
