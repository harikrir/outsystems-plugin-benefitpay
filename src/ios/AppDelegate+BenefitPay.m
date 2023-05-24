//
//  AppDelegate+BenefitPay.m
//
//  Created by Andre Grillo on 23/05/2023.
//

#import "AppDelegate+BenefitPay.h"
#import <objc/runtime.h>

@implementation AppDelegate (BenefitPay)

- (BPDLPaymentCallBackItem *)paymentCallback {
    return objc_getAssociatedObject(self, @selector(paymentCallback));
}

- (void)setPaymentCallback:(BPDLPaymentCallBackItem *)paymentCallback {
    objc_setAssociatedObject(self, @selector(paymentCallback), paymentCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    self.paymentCallback = [[BPDLPaymentCallBackItem alloc] initWithDeepLinkURL:url];
    
    NSString* statusString = [[NSString alloc] init];
    PaymentCallBackStatus status = self.paymentCallback.status;
    switch (status) {
        case PaymentCallBackStatusCancel:
            // Handle cancel status
            NSLog(@"Payment status is Cancel");
            statusString = @"cancelled";
            break;
        case PaymentCallBackStatusSuccess:
            // Handle success status
            NSLog(@"Payment status is Success");
            statusString = @"success";
            break;
        case PaymentCallBackStatusFail:
            // Handle fail status
            NSLog(@"Payment status is Fail");
            statusString = @"failed";
            break;
        default:
            statusString = @"unknown";
            break;
    }
    
    NSString *merchantName = (self.paymentCallback.merchantName == nil || self.paymentCallback.merchantName.length == 0) ? @"" : self.paymentCallback.merchantName;
    NSString *cardNumber = (self.paymentCallback.cardNumber == nil || self.paymentCallback.cardNumber.length == 0) ? @"" : self.paymentCallback.cardNumber;
    NSString *currency = (self.paymentCallback.currency == nil || self.paymentCallback.currency.length == 0) ? @"" : self.paymentCallback.currency;
    NSString *currencyCode = (self.paymentCallback.currencyCode == nil || self.paymentCallback.currencyCode.length == 0) ? @"" : self.paymentCallback.currencyCode;
    NSString *amount = (self.paymentCallback.amount == nil || self.paymentCallback.amount.length == 0) ? @"" : self.paymentCallback.amount;
    NSString *message = (self.paymentCallback.message == nil || self.paymentCallback.message.length == 0) ? @"" : self.paymentCallback.message;
    NSString *referenceId = (self.paymentCallback.referenceId == nil || self.paymentCallback.referenceId.length == 0) ? @"" : self.paymentCallback.referenceId;
    
    NSDictionary *userInfo = @{
        @"Status": statusString,
        @"MerchantName": merchantName,
        @"CardNumber": cardNumber,
        @"Currency": currency,
        @"CurrencyCode": currencyCode,
        @"Amount": amount,
        @"Message": message,
        @"ReferenceId": referenceId
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:kCallbackNotification object:nil userInfo:userInfo];
    
    return YES;
}

@end
