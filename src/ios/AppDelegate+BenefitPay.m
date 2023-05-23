//
//  AppDelegate+BenefitPay.m
//
//  Created by Andre Grillo on 23/05/2023.
//

#import "AppDelegate+BenefitPay.h"

@implementation AppDelegate (BenefitPay)

@dynamic paymentCallback;

- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    self.paymentCallback = [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];
    
    NSString* statusString = [[NSString alloc] init];
    PaymentCallBackStatus status = self.paymentCallback.status;
    switch (status) {
        case PaymentCallBackStatusCancel:
            // Handle cancel status
            NSLog(@"Payment status is Cancel");
            statusString = @"cancelled";
            break;
        case PaymentCallBackStatusSuccess:
            // Handle success status
            NSLog(@"Payment status is Success");
            statusString = @"success";
            break;
        case PaymentCallBackStatusFail:
            // Handle fail status
            NSLog(@"Payment status is Fail");
            statusString = @"failed";
            break;
        default:
            break;
    }
    
    NSDictionary *userInfo = @{
        @"Status": statusString,
        @"MerchantName": self.paymentCallback.merchantName,
        @"CardNumber": self.paymentCallback.cardNumber,
        @"Currency": self.paymentCallback.currencyCode,
        @"CurrencyCode": self.paymentCallback.currencyCode,
        @"Amount": self.paymentCallback.amount,
        @"Message": self.paymentCallback.message,
        @"ReferenceId": self.paymentCallback.referenceId
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:kCallbackNotification object:nil userInfo:userInfo];
    
    return YES;
}

@end
