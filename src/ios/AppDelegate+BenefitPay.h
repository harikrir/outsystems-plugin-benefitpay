// AppDelegate+BenefitPay.h

#import "AppDelegate.h"
#import <BenefitInAppSDK/BenefitInAppSDK.h>
#import "Constants.h"

@interface AppDelegate (BenefitPay)

@property (nonatomic, strong) BPDLPaymentCallBackItem *paymentCallback;

@end
