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
    
    [self.remindersSwitch setUserInteractionEnabled:NO];
    
    // Show time picker
    if (self.remindersSwitch.isOn) {
        [self.datePicker setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            [self.datePicker setAlpha:1.0];
        } completion:^(BOOL finished) {
            [self.remindersSwitch setUserInteractionEnabled:YES];
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

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
