//
//  AppDelegate.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "OMHClient.h"
#import "AppConstants.h"
#import "LoginViewController.h"
#import "MainViewController.h"

@interface AppDelegate () <OMHSignInDelegate>

@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [OMHClient setupClientWithAppGoogleClientID:[AppConstants googleClientID]
                                 appDSUClientID:kDSUClientID
                             appDSUClientSecret:[AppConstants DSUClientSecret]];
    
    UIViewController *root = nil;
    if (![OMHClient sharedClient].isSignedIn) {
        self.loginViewController = [[LoginViewController alloc] init];
        root = self.loginViewController;
    }
    else {
        root = self.navigationController;
        [OMHClient sharedClient].signInDelegate = self;
    }
    
    self.window.rootViewController = root;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (LoginViewController *)loginViewController
{
    if (_loginViewController == nil) {
        _loginViewController = [[LoginViewController alloc] init];
    }
    return _loginViewController;
}

- (UINavigationController *)navigationController
{
    if (_navigationController == nil) {
        MainViewController *mvc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:mvc];
        _navigationController = navcon;
    }
    return _navigationController;
}

- (void)userDidLogin
{
    UINavigationController *newRoot = self.navigationController;
    [UIView transitionFromView:self.loginViewController.view toView:newRoot.view duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.window.rootViewController = newRoot;
        self.loginViewController = nil;
    }];
}

- (void)userDidLogout
{
    LoginViewController *newRoot = self.loginViewController;
    
    UIView *fromView = nil;
    if (self.navigationController.topViewController.presentedViewController != nil) {
        fromView = self.navigationController.topViewController.presentedViewController.view;
    }
    else {
        fromView = self.navigationController.view;
    }
    
    [UIView transitionFromView:fromView toView:newRoot.view duration:0.35 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        self.window.rootViewController = newRoot;
        self.navigationController = nil;
    }];
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    NSLog(@"openURL: %@, source: %@, annotation: %@", url, sourceApplication, annotation);
    return [[OMHClient sharedClient] handleURL:url
                             sourceApplication:sourceApplication
                                    annotation:annotation];
}


#pragma mark - OMHSignInDelegate

- (void)OMHClient:(OMHClient *)client signInFinishedWithError:(NSError *)error
{
    if (error != nil) {
        [self userDidLogout];
    }
}

- (void)OMHClientSignInCancelled:(OMHClient *)client {}
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {}
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
