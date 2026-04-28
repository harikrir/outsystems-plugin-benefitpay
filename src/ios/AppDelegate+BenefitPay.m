#import "AppDelegate+BenefitPay.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
#import <objc/runtime.h>

// This must match the name used in your Swift file
NSString * const BenefitPayCallbackNotification = @"BenefitPayCallbackNotification";

@implementation AppDelegate (BenefitPay)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(application:openURL:options:);
        SEL swizzledSelector = @selector(benefit_application:openURL:options:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (BOOL)benefit_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    // 1. Call original implementation (OutSystems core logic)
    BOOL result = [self benefit_application:application openURL:url options:options];

    NSLog(@"[BenefitPay] Intercepted URL: %@", url.absoluteString);

    // 2. Initialize the SDK callback item
    BPDLPaymentCallBackItem *item = [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];

    if (!item) {
        NSLog(@"[BenefitPay] Not a BenefitPay callback or parsing failed.");
        return result;
    }

    [span_0](start_span)// 3. Map status based on the BPDLPaymentCallBackItem.h enum[span_0](end_span)
    NSString *statusStr = @"fail";
    if (item.status == PaymentCallBackStatusSuccess) {
        statusStr = @"success";
    } else if (item.status == PaymentCallBackStatusCancel) {
        statusStr = @"cancel";
    }

    NSDictionary *payload = @{
        @"status": statusStr,
        @"merchantName": item.merchantName ?: @"",
        @"cardNumber": item.cardNumber ?: @"",
        @"currency": item.currency ?: @"",
        @"currencyCode": item.currencyCode ?: @"",
        @"amount": item.amount ?: @"",
        @"message": item.message ?: @"",
        @"referenceId": item.referenceId ?: @""
    };

    // 4. CRITICAL: Post on Main Thread to ensure the Plugin captures it immediately
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BenefitPayCallbackNotification
                                                            object:nil
                                                          userInfo:payload];
    });

    return YES;
}

@end
