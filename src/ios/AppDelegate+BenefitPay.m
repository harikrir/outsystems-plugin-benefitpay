#import "AppDelegate+BenefitPay.h"
#import <objc/runtime.h>
#import <os/log.h> // Required for modern logging

@implementation AppDelegate (BenefitPay)

// Define a log category for easy filtering in Console.app
static os_log_t benefit_log;

+ (void)load {
    benefit_log = os_log_create("com.aub.benefitpay", "AppDelegate");
}

- (BPDLPaymentCallBackItem *)paymentCallback {
    return objc_getAssociatedObject(self, @selector(paymentCallback));
}

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback {
    objc_setAssociatedObject(self, @selector(paymentCallback), paymentCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    // Public logging ensures the URL is not redacted in the console
    os_log(benefit_log, "Deep link received: %{public}@", url.absoluteString);
    
    self.paymentCallback = [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];
    
    if (!self.paymentCallback) {
        os_log_error(benefit_log, "Error: Failed to initialize callback item from URL");
        return NO;
    }

    NSString* statusString = @"unknown";
    PaymentCallBackStatus status = self.paymentCallback.status;
    
    switch (status) {
        case PaymentCallBackStatusCancel:
            os_log(benefit_log, "Status: Cancelled");
            statusString = @"cancelled";
            break;
        case PaymentCallBackStatusSuccess:
            os_log(benefit_log, "Status: Success");
            statusString = @"success";
            break;
        case PaymentCallBackStatusFail:
            os_log_error(benefit_log, "Status: Failed");
            statusString = @"failed";
            break;
        default:
            os_log_error(benefit_log, "Status: Unknown (%ld)", (long)status);
            break;
    }
    
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

    os_log(benefit_log, "Posting internal notification: %{public}@", kCallbackNotification);
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallbackNotification object:nil userInfo:userInfo];
    
    return YES;
}
@end
