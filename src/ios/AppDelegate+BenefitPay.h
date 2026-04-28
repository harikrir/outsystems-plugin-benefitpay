#import "AppDelegate.h"

@class BPDLPaymentCallBackItem;

FOUNDATION_EXPORT NSString * const BenefitPayCallbackNotification;

@interface AppDelegate (BenefitPay)

@property (nonatomic, strong) BPDLPaymentCallBackItem *paymentCallback;

@end
