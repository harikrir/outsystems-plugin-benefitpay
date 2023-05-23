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
    
    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand){
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
                
                let andCallBackTag = "callbackTag_placeholder".lowercased()
                
                //Set the callback observer
                NotificationCenter.default.addObserver(self, selector: #selector(handleCallBack(_:)), name: NSNotification.Name(rawValue: "CallbackNotification"), object: nil)

                self.checkoutConfiguration = BPInAppConfiguration(appId: appId, andSecretKey: andSecretKey, andAmount: andAmount, andCurrencyCode: andCurrencyCode, andMerchantId: andMerchantId, andMerchantName: andMerchantName, andMerchantCity: andMerchantCity, andCountryCode: andCountryCode, andMerchantCategoryId: andMerchantCategoryId, andReferenceId: andReferenceId, andCallBackTag: andCallBackTag)
                
                self.bPButton = BPInAppButton()
                self.bPButton!.delegate = self
                guard let innerView = bPButton!.subviews.first, let button = innerView.subviews.first as? UIButton else {return}
                button.sendActions(for: .allTouchEvents)
                sendPluginResult(status: CDVCommandStatus_OK, message: "Payment Request sent", keepCallback: true)
                
            } else {
                sendPluginResult(status: CDVCommandStatus_ERROR, message: "Invalid checkout configuration: Invalid input Types")
            }
        } else {
            sendPluginResult(status: CDVCommandStatus_ERROR, message: "Invalid checkout configuration: There MUST be eleven input parameters")
        }
    }

    @objc func handleCallBack(_ notification: Notification) {
        if let callbackInfo = notification.userInfo as? [String: String] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: callbackInfo, options: [])
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                    sendPluginResult(status: CDVCommandStatus_OK, message: jsonString)
                }
            } catch {
                print("Error converting NSDictionary to JSON: \(error)")
                sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error converting callback to JSON: \(error)")
            }
        } else {
            sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: strange object received as callback")
        }
    }
   
    func sendPluginResult(status: CDVCommandStatus, message: String, keepCallback: Bool = false) {
        let pluginResult = CDVPluginResult(status: status, messageAs: message)
        if keepCallback {
            pluginResult?.keepCallback = true
        }
        if let callbackId = self.command!.callbackId {
            self.commandDelegate!.send(pluginResult, callbackId: callbackId)
        }
    }
}
