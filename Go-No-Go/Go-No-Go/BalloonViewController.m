//
//  BalloonViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 14/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "BalloonViewController.h"

@interface BalloonViewController ()

@end

@implementation BalloonViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)viewWillAppear:(BOOL)animated
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame)-10, CGRectGetHeight(self.view.frame)-10)];
    [label setText:@"Coming Soon"];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumScaleFactor:0.8];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
