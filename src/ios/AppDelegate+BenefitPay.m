#import "AppDelegate+BenefitPay.h"
#import <objc/runtime.h>

@implementation AppDelegate (BenefitPay)

- (BPDLPaymentCallBackItem *)paymentCallback {
    return objc_getAssociatedObject(self, @selector(paymentCallback));
}

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback {
    objc_setAssociatedObject(self, @selector(paymentCallback), paymentCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"[BenefitPay] Deep link received: %@", url.absoluteString);
    
    self.paymentCallback = [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];
    
    if (!self.paymentCallback) {
        NSLog(@"[BenefitPay] Error: Failed to initialize callback item from URL");
        return NO;
    }

    NSString* statusString = @"unknown";
    PaymentCallBackStatus status = self.paymentCallback.status;
    
    switch (status) {
        case PaymentCallBackStatusCancel:
            NSLog(@"[BenefitPay] Status: Cancelled");
            statusString = @"cancelled";
            break;
        case PaymentCallBackStatusSuccess:
            NSLog(@"[BenefitPay] Status: Success");
            statusString = @"success";
            break;
        case PaymentCallBackStatusFail:
            NSLog(@"[BenefitPay] Status: Failed");
            statusString = @"failed";
            break;
        default:
            NSLog(@"[BenefitPay] Status: Unknown (%ld)", (long)status);
            break;
    }
    
    // Helper to avoid nil values in dictionary
    #define SafeString(str) (str == nil ? @"" : str)
    
    NSDictionary *userInfo = @{
        @"status": statusString,
        @"merchantName": SafeString(self.paymentCallback.merchantName),
        @"cardNumber": SafeString(self.paymentCallback.cardNumber),
        @"currency": SafeString(self.paymentCallback.currency),
        @"currencyCode": SafeString(self.paymentCallback.currencyCode),
        @"amount": SafeString(self.paymentCallback.amount),
        @"message": SafeString(self.paymentCallback.message),
        @"referenceId": SafeString(self.paymentCallback.referenceId)
    };

    NSLog(@"[BenefitPay] Posting notification: %@", kCallbackNotification);
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallbackNotification object:nil userInfo:userInfo];
    
    return YES;
}
@end
