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
    NSLog(@"✅ [BenefitPay] openURL received: %@", url.absoluteString);

    if (!url) {
        NSLog(@"❌ [BenefitPay] URL is nil");
        return YES; // ✅ NEVER return NO in Cordova
    }

    BPDLPaymentCallBackItem *item =
        [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!item) {
        NSLog(@"❌ [BenefitPay] SDK did NOT recognize callback URL");
        NSLog(@"❌ [BenefitPay] Raw URL = %@", url.absoluteString);
        return YES; // ✅ CRITICAL for Cordova
    }

    NSLog(@"✅ [BenefitPay] Callback parsed successfully");

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

    NSLog(@"✅ [BenefitPay] Posting callback notification");

    [[NSNotificationCenter defaultCenter]
        postNotificationName:BenefitPayCallbackNotification
                      object:nil
                    userInfo:payload];

    return YES; // ✅ ALWAYS YES
}

@end
