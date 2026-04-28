#import "AppDelegate+BenefitPay.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>

NSString * const BenefitPayCallbackNotification =
    @"BenefitPayCallbackNotification";

@implementation AppDelegate (BenefitPay)

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BPDLPaymentCallBackItem *item =
      [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!item) return NO;

    NSString *status = @"failed";
    if (item.status == PaymentCallBackStatusSuccess) status = @"success";
    else if (item.status == PaymentCallBackStatusCancel) status = @"cancelled";

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
``
