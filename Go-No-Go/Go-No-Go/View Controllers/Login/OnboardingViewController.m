//
//  OnboardingViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 20/03/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "OnboardingViewController.h"
#import "AppConstants.h"

@interface OnboardingViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *codeTextField;

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gesture];
    
    self.codeTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidGoThroughResearcherCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)dismissView:(id)sender {
    
    // Save Code
    [[NSUserDefaults standardUserDefaults] setObject:self.codeTextField.text forKey:kResearcherCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.codeTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Leave page
    [self dismissKeyboard];
    [self dismissView:nil];
    return NO;
}

@end
