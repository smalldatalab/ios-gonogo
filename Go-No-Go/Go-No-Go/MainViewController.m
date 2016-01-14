//
//  ViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

//------------------------------------------------------------------------------------------
#pragma mark - View Lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------------------
#pragma mark - IBActions -
//------------------------------------------------------------------------------------------

- (IBAction)showSignup:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Signup" message:@"Coming Soon." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)showSelfReports:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Self-Reports" message:@"Coming Soon." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
