#import "AppDelegate+BenefitPay.h"
#import "Constants.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    // ✅ Benefit-required call
    BPDLPaymentCallBackItem *item =
        [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!item) {
        return NO;
    }

    self.paymentCallback = item;

    NSString *statusString = @"unknown";
    switch (item.status) {
        case PaymentCallBackStatusCancel:
            statusString = @"cancelled";
            break;
        case PaymentCallBackStatusSuccess:
            statusString = @"success";
            break;
        case PaymentCallBackStatusFail:
            statusString = @"failed";
            break;
        default:
            break;
    }

    NSDictionary *userInfo = @{
        @"status": statusString,
        @"merchantName": item.merchantName ?: @"",
        @"cardNumber":  item.cardNumber ?: @"",
        @"currency":    item.currency ?: @"",
        @"currencyCode":item.currencyCode ?: @"",
        @"amount":      item.amount ?: @"",
        @"message":     item.message ?: @"",
        @"referenceId": item.referenceId ?: @""
    };

    [[NSNotificationCenter defaultCenter]
        postNotificationName:kCallbackNotification
                      object:nil
                    userInfo:userInfo];

    return YES;
}

@end
