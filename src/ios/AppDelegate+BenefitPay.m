#import "AppDelegate+BenefitPay.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
#import <objc/runtime.h>

// ✅ THIS MUST PRINT
__attribute__((constructor))
static void BenefitPayLoaded(void) {
    NSLog(@"🔥🔥🔥 AppDelegate+BenefitPay LOADED");
    fprintf(stderr, "🔥 STDERR AppDelegate+BenefitPay LOADED\n");
}

NSString * const BenefitPayCallbackNotification =
    @"BenefitPayCallbackNotification";

@implementation AppDelegate (BenefitPay)

static const void *kPaymentCallbackKey = &kPaymentCallbackKey;

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback {
    objc_setAssociatedObject(
        self,
        kPaymentCallbackKey,
        paymentCallback,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC
    );
}

- (BPDLPaymentCallBackItem *)paymentCallback {
    return objc_getAssociatedObject(self, kPaymentCallbackKey);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSLog(@"✅✅✅ openURL HIT");
    NSLog(@"✅ RAW URL: %@", url.absoluteString);

    if (!url) return YES;

    BPDLPaymentCallBackItem *item =
        [[BPDLPaymentCallBackItem alloc]
            initWithDeepLinkURL:url];

    if (!item) {
        NSLog(@"❌ SDK did not parse URL");
        return YES;
    }

    self.paymentCallback = item;

    NSString *status = @"fail";
    if (item.status == PaymentCallBackStatusSuccess) {
        status = @"success";
    } else if (item.status == PaymentCallBackStatusCancel) {
        status = @"cancel";
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
