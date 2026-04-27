import Foundation
import BenefitInAppSDK

@objc(BenefitPay)
class BenefitPay: CDVPlugin, BPInAppButtonDelegate {
    var checkoutConfiguration: BPInAppConfiguration?
    var lastCommand: CDVInvokedUrlCommand? // Renamed to avoid confusion
    var bPButton: BPInAppButton?
    
    // Constant string must match Objective-C: "CallbackNotification"
    let notificationName = Notification.Name("CallbackNotification")
    
    override func pluginInitialize() {
        super.pluginInitialize()
        // Add observer once when plugin loads
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallBack(_:)), name: notificationName, object: nil)
        print("[BenefitPay] Plugin initialized and observer added.")
    }
    
    func bpInAppConfiguration() -> BPInAppConfiguration? {
        return checkoutConfiguration
    }
    
    @objc(checkout:)
    func checkout(_ command: CDVInvokedUrlCommand){
        self.lastCommand = command
        print("[BenefitPay] Checkout initiated...")
        
        // Note: Your check says 10, but your error message says 11. 
        // I've kept it at 10 to match your current logic.
        guard command.arguments.count == 10 else {
            let errorMsg = "{\"status\": \"failed\", \"message\": \"Invalid arguments: Expected 10, got \(command.arguments.count)\"}"
            print("[BenefitPay] Error: \(errorMsg)")
            self.sendPluginResult(status: CDVCommandStatus_ERROR, message: errorMsg)
            return
        }
        
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
            
            let andCallBackTag = "com.outsystems.experts.BenefitPay".lowercased()
            
            self.checkoutConfiguration = BPInAppConfiguration(appId: appId, andSecretKey: andSecretKey, andAmount: andAmount, andCurrencyCode: andCurrencyCode, andMerchantId: andMerchantId, andMerchantName: andMerchantName, andMerchantCity: andMerchantCity, andCountryCode: andCountryCode, andMerchantCategoryId: andMerchantCategoryId, andReferenceId: andReferenceId, andCallBackTag: andCallBackTag)
            
            print("[BenefitPay] Configuration set for Reference: \(andReferenceId)")
            
            self.bPButton = BPInAppButton()
            self.bPButton!.delegate = self
            
            // Simulating button click to trigger SDK
            DispatchQueue.main.async {
                if let innerView = self.bPButton!.subviews.first, 
                   let button = innerView.subviews.first as? UIButton {
                    print("[BenefitPay] Triggering SDK Button Click")
                    button.sendActions(for: .touchUpInside)
                } else {
                    print("[BenefitPay] Error: Could not find internal SDK button")
                }
            }
            
        } else {
            self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "{\"status\": \"failed\", \"message\": \"Invalid input types\"}")
        }
    }
    
    @objc func handleCallBack(_ notification: Notification) {
        print("[BenefitPay] Notification received in Swift observer")
        
        guard let callbackInfo = notification.userInfo as? [String: Any] else {
            print("[BenefitPay] Error: Notification userInfo is null or invalid")
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: callbackInfo, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[BenefitPay] Sending to Cordova: \(jsonString)")
                
                let status = callbackInfo["status"] as? String
                if status == "success" {
                    self.sendPluginResult(status: CDVCommandStatus_OK, message: jsonString)
                } else {
                    self.sendPluginResult(status: CDVCommandStatus_ERROR, message: jsonString)
                }
            }
        } catch {
            print("[BenefitPay] JSON Error: \(error.localizedDescription)")
            self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "JSON Serialization failed")
        }
    }
    
    func sendPluginResult(status: CDVCommandStatus, message: String) {
        guard let command = self.lastCommand else { 
            print("[BenefitPay] No command found to return result to.")
            return 
        }
        let pluginResult = CDVPluginResult(status: status, messageAs: message)
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
