//
//  BalloonViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 14/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "BalloonViewController.h"

@interface BalloonViewController ()

@property (nonatomic, strong) UIImageView *balloon;
@property (nonatomic, strong) IBOutlet UILabel *potentialGainLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalEarningsLabel;

@property (nonatomic, assign) double earnings;  // so far
@property (nonatomic, assign) double gains;     // on current pumping

@end

@implementation BalloonViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Done button to dismiss views
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
    
    // Data
    self.earnings = 0;
    self.gains = 0;
    [self updateEarningLabels];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Balloon image
    self.balloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balloon"]];
    self.balloon.center = self.view.center;
    [self.view addSubview:self.balloon];
    [self.view sendSubviewToBack:self.balloon];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Actions -
//------------------------------------------------------------------------------------------

- (IBAction)tappedPump:(id)sender
{
    // Prevent the balloon from becoming too large for the screen
    if (CGRectGetWidth(self.balloon.frame) + 40 >= CGRectGetWidth(self.view.frame) ||
        CGRectGetHeight(self.balloon.frame) + 100 >= CGRectGetHeight(self.view.frame)) {
        return;
    }
    
    // Inflate balloon by a factor of 1.055,1.05
    // (Slightly more on the x-axis to mimic real balloon)
    CGAffineTransform transform = CGAffineTransformScale(self.balloon.transform, 1.055, 1.05);
    [self.balloon setTransform:transform];
    
    // Update data
    self.gains += 0.05;
    [self updateEarningLabels];
}

- (IBAction)tappedCollect:(id)sender
{
    // Reset balloon size
    [self.balloon setTransform:CGAffineTransformIdentity];
    
    // Update data
    self.earnings += self.gains;
    self.gains = 0;
    [self updateEarningLabels];
}

//------------------------------------------------------------------------------------------
#pragma mark - Data -
//------------------------------------------------------------------------------------------

- (void)updateEarningLabels
{
    self.totalEarningsLabel.text = [NSString stringWithFormat:@"Total Earnings: $%.2f", self.earnings];
    self.potentialGainLabel.text = [NSString stringWithFormat:@"Potential Gain: $%.2f", self.gains];
}

@end
