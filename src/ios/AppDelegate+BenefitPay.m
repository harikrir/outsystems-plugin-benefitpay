//
//  AppDelegate+BenefitPay.m
//
//  Created by Andre Grillo on 23/05/2023.
//

#import "AppDelegate+BenefitPay.h"
#import <objc/runtime.h>

@implementation AppDelegate (BenefitPay)


- (BPDLPaymentCallBackItem *)paymentCallback {
    return objc_getAssociatedObject(self, @selector(paymentCallback));
}

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback {
    objc_setAssociatedObject(self, @selector(paymentCallback), paymentCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
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
