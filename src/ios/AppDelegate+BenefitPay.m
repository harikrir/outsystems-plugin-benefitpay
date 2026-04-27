// AppDelegate+BenefitPay.m

#import "AppDelegate+BenefitPay.h"
#import <objc/runtime.h>

@implementation AppDelegate (BenefitPay)

// Store callback object
- (BPDLPaymentCallBackItem *)paymentCallback {
    return objc_getAssociatedObject(self, @selector(paymentCallback));
}

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback {
    objc_setAssociatedObject(
        self,
        @selector(paymentCallback),
        paymentCallback,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );
}

// Deep link callback from BenefitPay app
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    self.paymentCallback =
        [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!self.paymentCallback) {
        return NO;
    }

    NSString *statusString = @"failed";

    switch (self.paymentCallback.status) {
        case PaymentCallBackStatusSuccess:
            statusString = @"success";
            break;
        case PaymentCallBackStatusCancel:
            statusString = @"cancelled";
            break;
        case PaymentCallBackStatusFail:
        default:
            statusString = @"failed";
            break;
    }

    NSDictionary *userInfo = @{
        @"status": statusString,
        @"merchantName": self.paymentCallback.merchantName ?: @"",
        @"cardNumber": self.paymentCallback.cardNumber ?: @"",
        @"currency": self.paymentCallback.currency ?: @"",
        @"currencyCode": self.paymentCallback.currencyCode ?: @"",
        @"amount": self.paymentCallback.amount ?: @"",
        @"message": self.paymentCallback.message ?: @"",
        @"referenceId": self.paymentCallback.referenceId ?: @""
    };

    [[NSNotificationCenter defaultCenter]
        postNotificationName:kCallbackNotification
                      object:nil
                    userInfo:userInfo];

    return YES;
}

@end
