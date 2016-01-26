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

static NSString * const kHasRequestedPermissionKey = @"HAS_REQUESTED_PERMISSION";
static NSString * const kDailyReminderTime         = @"DAILY_REMINDER_TIME";

@interface ProfileViewController ()

@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UISwitch *remindersSwitch;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation ProfileViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure UI
    self.usernameLabel.text          = [OMHClient signedInUsername] ?: @"N/A";
    self.logoutButton.tintColor      = [UIColor belizeBlueColor];
    self.doneButton.tintColor        = [UIColor belizeBlueColor];
    self.remindersSwitch.onTintColor = [UIColor belizeBlueColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Configure date picker
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.remindersSwitch.frame) + 8.f, CGRectGetWidth(self.view.frame), 200.f)];
    [self.datePicker setDatePickerMode:UIDatePickerModeTime];
    [self.datePicker setDate:[NSDate date]];
    [self.datePicker setHidden:YES];
    [self.datePicker setAlpha:0.0];
    [self.view addSubview:self.datePicker];
    
    // If a reminder time is saved, use it, else use current time
    NSDate *reminderTime = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kDailyReminderTime];
    self.datePicker.date    = reminderTime ?: [NSDate date];
    self.remindersSwitch.on = [self hasRemindersEnabled];
    [self updateDatePickerAppearance];
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
    [self updateDatePickerAppearance];
}

- (void)updateDatePickerAppearance {
    
    // Prevent user from messing with switch during animation
    [self.remindersSwitch setUserInteractionEnabled:NO];
    
    // Show time picker
    if (self.remindersSwitch.isOn) {
        [self.datePicker setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            [self.datePicker setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self.remindersSwitch setUserInteractionEnabled:YES];
            
            // Check for notification permissions
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                [self requestNotificationPermissions];
            }
            
        }];
    }
    
    // Hide date picker
    else {
        [UIView animateWithDuration:0.3 animations:^{
            [self.datePicker setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.datePicker setHidden:YES];
            [self.remindersSwitch setUserInteractionEnabled:YES];
        }];
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
        message = @"To deliver reminders, Go/No-Go needs permission to display notifications. Please allow notifications for Go/No-Go.";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRequestedPermissionKey];
    }
    else {
        title = @"Insufficient Permissions";
        message = @"To deliver reminders, Go/No-Go needs permission to display notifications. Please enable notifications for Go/No-Go in your device settings.";
        
        // Reset to OFF
        [self.remindersSwitch setOn:NO animated:YES];
        [self updateDatePickerAppearance];
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
        
        // Create new local notification
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody      = @"Daily reminder to answer questions";// Should change text
        notification.fireDate       = self.datePicker.date;
        notification.repeatInterval = NSCalendarUnitDay;
        notification.soundName      = UILocalNotificationDefaultSoundName;
        notification.timeZone       = [NSTimeZone defaultTimeZone];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        // Save it to user defaults
        [[NSUserDefaults standardUserDefaults] setObject:self.datePicker.date forKey:kDailyReminderTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
