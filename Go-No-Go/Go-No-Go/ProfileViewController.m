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
@property (nonatomic, strong) IBOutlet UIButton *logoutButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation ProfileViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text     = [OMHClient signedInUsername] ?: @"";
    self.logoutButton.tintColor = [UIColor belizeBlueColor];
    self.doneButton.tintColor   = [UIColor belizeBlueColor];
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

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
