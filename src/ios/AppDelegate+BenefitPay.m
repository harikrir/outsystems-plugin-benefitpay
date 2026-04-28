#import "AppDelegate+BenefitPay.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
#import <objc/runtime.h>

NSString * const BenefitPayCallbackNotification =
    @"BenefitPayCallbackNotification";

@implementation AppDelegate (BenefitPay)

#pragma mark - Method Swizzling

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector =
            @selector(application:openURL:options:);
        SEL swizzledSelector =
            @selector(benefit_application:openURL:options:);

        Method originalMethod =
            class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod =
            class_getInstanceMethod(class, swizzledSelector);

        method_exchangeImplementations(
            originalMethod,
            swizzledMethod
        );
    });
}

#pragma mark - Swizzled implementation

- (BOOL)benefit_application:(UIApplication *)application
                    openURL:(NSURL *)url
                    options:(NSDictionary *)options
{
    // ✅ Call original OutSystems implementation
    BOOL result =
        [self benefit_application:application
                           openURL:url
                           options:options];

    NSLog(@"✅ [BenefitPay] openURL intercepted: %@",
          url.absoluteString);

    BPDLPaymentCallBackItem *item =
        [[BPDLPaymentCallBackItem alloc]
            initWithDeepLinkURL:url];

    if (!item) {
        NSLog(@"❌ Not a BenefitPay callback");
        return result;
    }

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

    return result;
}

@end
