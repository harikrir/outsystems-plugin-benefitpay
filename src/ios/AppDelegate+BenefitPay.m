#import "AppDelegate+BenefitPay.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
#import <objc/runtime.h>

NSString * const BenefitPayCallbackNotification =
    @"BenefitPayCallbackNotification";

@implementation AppDelegate (BenefitPay)

static const void *kPaymentCallbackKey = &kPaymentCallbackKey;

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback
{
    objc_setAssociatedObject(
        self,
        kPaymentCallbackKey,
        paymentCallback,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );
}

- (BPDLPaymentCallBackItem *)paymentCallback
{
    return objc_getAssociatedObject(self, kPaymentCallbackKey);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if (!url) return NO;

    BPDLPaymentCallBackItem *item =
        [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!item) return NO;

    self.paymentCallback = item;

    NSString *status = @"failed";
    if (item.status == PaymentCallBackStatusSuccess) {
        status = @"success";
    } else if (item.status == PaymentCallBackStatusCancel) {
        status = @"cancelled";
    }

    NSDictionary *payload = @{
        @"status": status,
        @"merchantName": item.merchantName ?: @"",
        @"cardNumber": item.cardNumber ?: @"",
        @"currency": item.currency ?: @"",
        @"currencyCode": item.currencyCode ?: @"",
        @"amount": item.amount ?: @"",
        @"message": item.message ?: @"",
        @"referenceId": item.referenceId ?: @""
    };

    [[NSNotificationCenter defaultCenter]
        postNotificationName:BenefitPayCallbackNotification
                      object:nil
                    userInfo:payload];

    return YES;
}

@end
