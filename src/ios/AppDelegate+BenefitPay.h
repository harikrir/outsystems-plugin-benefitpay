//
//  AppDelegate+BenefitPay.h
//
//  Created by Andre Grillo on 23/05/2023.
//

#import "AppDelegate.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
#import "Constants.h"

@interface AppDelegate (BenefitPay)

@property (nonatomic, strong) BPDLPaymentCallBackItem *paymentCallback;

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end
