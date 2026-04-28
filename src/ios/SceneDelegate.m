#import "SceneDelegate.h"
#import "AppDelegate.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts
{
    NSURL *url = URLContexts.anyObject.URL;
    if (!url) return;

    AppDelegate *delegate =
        (AppDelegate *)UIApplication.sharedApplication.delegate;

    [delegate application:UIApplication.sharedApplication
                  openURL:url
                  options:@{}];
}

@end
