//
//  LoginViewController.m
//  PAM
//
//  Created by Charles Forkish on 11/23/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "LoginViewController.h"
#import "UIView+AutoLayoutHelpers.h"
#import "AppDelegate.h"
#import "OMHClient.h"
#import "DSUURLViewController.h"

@interface LoginViewController () <OMHSignInDelegate, UITextFieldDelegate>


@property (nonatomic, strong) UITextField *userTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *signInButton;
@property (nonatomic, weak) UIButton *googleSignInButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *signInFailureLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor belizeBlueColor]];
    
    UILabel *header = [[UILabel alloc] init];
    header.text = @"Go/No-Go";
    header.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:45.0];
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [UIColor whiteColor];
    
    UIView *frame = [[UIView alloc] init];
    frame.backgroundColor = [UIColor whiteColor];
    frame.layer.cornerRadius = 8.0;
    
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    
    UITextField *userField = [[UITextField alloc] init];
    userField.backgroundColor = [UIColor whiteColor];
    userField.placeholder = @"Username";
    userField.delegate = self;
    userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.userTextField = userField;
    
    UITextField *passField = [[UITextField alloc] init];
    passField.backgroundColor = [UIColor whiteColor];
    passField.placeholder = @"Password";
    passField.secureTextEntry = YES;
    passField.delegate = self;
    self.passwordTextField = passField;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 8.0;
    [button setTitle:@"Sign In" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor belizeBlueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(signInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.signInButton = button;
    [self setSignInButtonEnabled:NO];
    
    [self.view addSubview:header];
    [self.view addSubview:frame];
    [frame addSubview:userField];
    [frame addSubview:separator];
    [frame addSubview:passField];
    [self.view addSubview:button];
    
    [frame constrainHeight:61];
    [userField constrainHeight:30];
    [passField constrainHeight:30];
    [button constrainSize:CGSizeMake(200, 30)];
    
    [self.view constrainChildToDefaultHorizontalInsets:header];
    [self.view constrainChildToDefaultHorizontalInsets:frame];
    [frame constrainChildToDefaultHorizontalInsets:userField];
    [frame constrainChild:separator toHorizontalInsets:UIEdgeInsetsZero];
    [frame constrainChildToDefaultHorizontalInsets:passField];
    [button centerHorizontallyInView:self.view];
    
    [header constrainToTopInParentWithMargin:70];
    [frame positionBelowElement:header margin:30];
    [userField constrainToTopInParentWithMargin:0];
    [passField constrainToBottomInParentWithMargin:0];
    [separator positionBelowElement:userField margin:0];
    [separator positionAboveElement:passField margin:0];
    [button positionBelowElement:frame margin:30];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeSystem];
    settings.tintColor = [UIColor whiteColor];
    [settings setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settings addTarget:self action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    [settings constrainSize:CGSizeMake(25, 25)];
    [self.view addSubview:settings];
    [settings constrainToLeftInParentWithMargin:10];
    [settings constrainToBottomInParentWithMargin:10];
    
    [OMHClient sharedClient].signInDelegate = self;
    
    [self setupGoogleSignInButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)setupGoogleSignInButton
{
    if (self.googleSignInButton) {
        [self.googleSignInButton removeFromSuperview];
        self.googleSignInButton = nil;
    }
    
    UIButton *googleButton = [OMHClient googleSignInButton];
    [googleButton addTarget:self action:@selector(signInButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:googleButton];
    [self.view constrainChildToDefaultHorizontalInsets:googleButton];
    [googleButton constrainToBottomInParentWithMargin:80];
    
    [OMHClient sharedClient].signInDelegate = self;
    self.googleSignInButton = googleButton;
}

- (void)signInButtonPressed:(id)sender
{
    if ([sender isEqual:self.signInButton]) {
        [[OMHClient sharedClient] signInWithUsername:self.userTextField.text
                                            password:self.passwordTextField.text];
    }
    
    if (self.signInFailureLabel != nil) {
        [self.signInFailureLabel removeFromSuperview];
        self.signInFailureLabel = nil;
    }
    
    [self setSignInButtonEnabled:NO];
    self.googleSignInButton.enabled = NO;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicator];
    [indicator centerHorizontallyInView:self.view];
    [indicator positionBelowElement:self.signInButton margin:30];
    [indicator startAnimating];
    self.activityIndicator = indicator;
}

- (void)presentSignInFailureMessage
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Sign in failed";
    [label sizeToFit];
    [self.view addSubview:label];
    [label centerHorizontallyInView:self.view];
    [label positionBelowElement:self.signInButton margin:30];
    self.signInFailureLabel = label;
}

- (void)presentSettingsViewController
{
    DSUURLViewController *vc = [[DSUURLViewController alloc] init];
    UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navcon animated:YES completion:nil];
}

- (void)setSignInButtonEnabled:(BOOL)enabled
{
    self.signInButton.enabled = enabled;
    self.signInButton.alpha = enabled ? 1.0 : 0.65;
}

- (void)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - OMHSignInDelegate

- (void)OMHClient:(OMHClient *)client signInFinishedWithError:(NSError *)error
{
    if (error != nil) {
        NSLog(@"OMHClientLoginFinishedWithError: %@", error);
        
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        
        [self setSignInButtonEnabled:(self.userTextField.text.length > 0 && self.passwordTextField.text.length > 0)];
        self.googleSignInButton.enabled = YES;
        
        [self presentSignInFailureMessage];
        return;
    }
    
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [(AppDelegate *)[UIApplication sharedApplication].delegate userDidLogin];
    }
}

- (void)OMHClientSignInCancelled:(OMHClient *)client
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    [self setSignInButtonEnabled:YES];
    self.googleSignInButton.enabled = YES;
    
    if (self.presentedViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL enable = NO;
    if (range.location == 0) {
        if (string.length > 0) {
            if ([textField isEqual:self.userTextField]) {
                enable = self.passwordTextField.text.length > 0;
            }
            else {
                enable = self.userTextField.text.length > 0;
            }
        }
    }
    else {
        enable = (self.userTextField.text.length > 0 && self.passwordTextField.text.length > 0);
    }
    [self setSignInButtonEnabled:enable];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
