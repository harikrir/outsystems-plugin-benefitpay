#import "AppDelegate+BenefitPay.h"
#import "Constants.h"
#import <objc/runtime.h>

@implementation AppDelegate (BenefitPay)

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

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSLog(@"✅ BenefitPay openURL: %@", url.absoluteString);

    self.paymentCallback =
        [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!self.paymentCallback) return NO;

    NSString *status = @"failed";
    switch (self.paymentCallback.status) {
        case PaymentCallBackStatusSuccess: status = @"success"; break;
        case PaymentCallBackStatusCancel:  status = @"cancelled"; break;
        default:                           status = @"failed"; break;
    }

    NSDictionary *userInfo = @{
        @"status": status,
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
