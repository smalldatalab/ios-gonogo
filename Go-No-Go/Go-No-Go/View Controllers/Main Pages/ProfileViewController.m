//
//  ProfileViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 19/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "ProfileViewController.h"
#import "OMHClient.h"
#import "AppDelegate.h"
#import "AppConstants.h"
#import "VASTableViewController.h"

@interface ProfileViewController ()

@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UISwitch *remindersSwitch;
@property (nonatomic, strong) IBOutlet UIButton *completeBaselineButton;

@end

@implementation ProfileViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure UI
    self.usernameLabel.text               = [OMHClient signedInUsername] ?: @"N/A";
    self.logoutButton.tintColor           = [UIColor belizeBlueColor];
    self.doneButton.tintColor             = [UIColor belizeBlueColor];
    self.remindersSwitch.onTintColor      = [UIColor belizeBlueColor];
    self.completeBaselineButton.tintColor = [UIColor belizeBlueColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.remindersSwitch.on = [self hasRemindersEnabled];
}

- (IBAction)donePressed:(id)sender {
    [self updateReminders];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Actions -
//------------------------------------------------------------------------------------------

- (IBAction)logoutPressed:(id)sender {
    // Logout from app
    [[OMHClient sharedClient] signOut];
    [(AppDelegate *)[UIApplication sharedApplication].delegate userDidLogout];
}

- (IBAction)remindersSwitchChanged:(id)sender {
    if (self.remindersSwitch.isOn) {
        // Check for notification permissions
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            [self requestNotificationPermissions];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"completeBaselineSegue"]) {
        UINavigationController *nav = (UINavigationController*)[segue destinationViewController];
        VASTableViewController *vas = (VASTableViewController*)[nav topViewController];
        vas.testType = baselineTestType;
    }
}

//------------------------------------------------------------------------------------------
#pragma mark - Reminders -
//------------------------------------------------------------------------------------------

- (BOOL)hasRemindersEnabled {
    return ([[[UIApplication sharedApplication] scheduledLocalNotifications] count] > 0);
}

- (void)requestNotificationPermissions
{
    UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;

    // Already enabled, we're fine
    if ((settings.types & UIUserNotificationTypeAlert)) return;
    
    NSString *title;
    NSString *message;
    BOOL hasRequested = [[NSUserDefaults standardUserDefaults] boolForKey:kHasRequestedPermissionKey];
    
    if (!hasRequested) {
        title = @"Reminder Permissions";
        message = @"To deliver reminders, Pulsus needs permission to display notifications. Please allow notifications for Pulsus.";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRequestedPermissionKey];
    }
    else {
        title = @"Insufficient Permissions";
        message = @"To deliver reminders, Pulsus needs permission to display notifications. Please enable notifications for Pulsus in your device settings.";
        
        // Reset to OFF
        [self.remindersSwitch setOn:NO animated:YES];
    }
    
    // Notify the user then register local notifications
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Default 'OK' action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }];
    [alertController addAction:okAction];
    
    // If already requested, add action to open settings
    if (hasRequested) {
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:settingsAction];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateReminders {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (self.remindersSwitch.isOn) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        [components setHour: 10];
        [components setMinute: 0];
        [components setSecond: 0];
        [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
        NSDate *morningTime = [calendar dateFromComponents:components];
        
        [components setHour:19];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *eveningTime = [calendar dateFromComponents:components];
        
        // Create morning notification
        UILocalNotification *morningNotification = [[UILocalNotification alloc] init];
        morningNotification.alertBody      = @"Daily reminder to answer questions";// Should change text
        morningNotification.fireDate       = morningTime;
        morningNotification.repeatInterval = NSCalendarUnitDay;
        morningNotification.soundName      = UILocalNotificationDefaultSoundName;
        morningNotification.timeZone       = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:morningNotification];
        
        // Create evening notification
        UILocalNotification *eveningNotification = [[UILocalNotification alloc] init];
        eveningNotification.alertBody      = @"Daily reminder to answer questions";// Should change text
        eveningNotification.fireDate       = eveningTime;
        eveningNotification.repeatInterval = NSCalendarUnitDay;
        eveningNotification.soundName      = UILocalNotificationDefaultSoundName;
        eveningNotification.timeZone       = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:eveningNotification];
    }
}

@end
