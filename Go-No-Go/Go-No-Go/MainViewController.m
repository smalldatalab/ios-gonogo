//
//  ViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "MainViewController.h"
#import "UIColor+Additions.h"

@interface MainViewController ()

@end

@implementation MainViewController

//------------------------------------------------------------------------------------------
#pragma mark - View Lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Button for profile page
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user"] style:UIBarButtonItemStylePlain target:self action:@selector(openProfile)];
    item.tintColor = [UIColor belizeBlueColor];
    [self.navigationItem setLeftBarButtonItem:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------
#pragma mark - Actions -
//------------------------------------------------------------------------------------------

- (void)openProfile {
    UINavigationController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavigationController"];
    [self presentViewController:pvc animated:YES completion:nil];
}

- (IBAction)showSelfReports:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Self-Reports" message:@"Coming Soon." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
