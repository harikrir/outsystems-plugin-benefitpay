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
    
    NSString* merchantName = [[NSString alloc] init];
    NSString* cardNumber = [[NSString alloc] init];
    NSString* currency = [[NSString alloc] init];
    NSString* currencyCode = [[NSString alloc] init];
    NSString* amount = [[NSString alloc] init];
    NSString* message = [[NSString alloc] init];
    NSString* referenceId = [[NSString alloc] init];
    
    if (self.paymentCallback.merchantName == nil || [self.paymentCallback.merchantName length] == 0) {
        merchantName = @"";
    } else {
        merchantName = self.paymentCallback.merchantName;
    }
    
    if (self.paymentCallback.cardNumber == nil || [self.paymentCallback.cardNumber length] == 0) {
        cardNumber = @"";
    } else {
        cardNumber = self.paymentCallback.cardNumber;
    }
    
    if (self.paymentCallback.currency == nil || [self.paymentCallback.currency length] == 0) {
        currency = @"";
    } else {
        currency = self.paymentCallback.currency;
    }
        
    if (self.paymentCallback.currencyCode == nil || [self.paymentCallback.currencyCode length] == 0) {
        currencyCode = @"";
    } else {
        currencyCode = self.paymentCallback.currencyCode;
    }
    
    if (self.paymentCallback.amount == nil || [self.paymentCallback.amount length] == 0) {
        amount = @"";
    } else {
        amount = self.paymentCallback.amount;
    }
    
    if (self.paymentCallback.message == nil || [self.paymentCallback.message length] == 0) {
        message = @"";
    } else {
        message = self.paymentCallback.message;
    }
    
    if (self.paymentCallback.referenceId == nil || [self.paymentCallback.referenceId length] == 0) {
        referenceId = @"";
    } else {
        referenceId = self.paymentCallback.referenceId;
    }
    
    
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
