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

- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
