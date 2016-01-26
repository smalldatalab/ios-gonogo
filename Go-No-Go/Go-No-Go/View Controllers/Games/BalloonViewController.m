//
//  BalloonViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 14/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "BalloonViewController.h"
#import "UIView+Explode.h"

static CGFloat const kPumpFactor  = 1.1;
static CGFloat const kGainPerPump = 0.25;
static NSInteger const kMaxPumps  = 12;

@interface BalloonViewController ()

@property (nonatomic, strong) UIImageView *balloon;
@property (nonatomic, strong) IBOutlet UILabel *potentialGainLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalEarningsLabel;
@property (nonatomic, strong) IBOutlet UIButton *pumpButton;
@property (nonatomic, strong) IBOutlet UIButton *collectButton;

@property (nonatomic, assign) double earnings;
@property (nonatomic, assign) double potentialGain;
@property (nonatomic, assign) int pumps;
@property (nonatomic, assign) int positionToImplode;

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
    self.potentialGain = 0;
    self.pumps = 0;
    self.positionToImplode = kMaxPumps + 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Set up the balloon on the screen
    [self resetBalloon];
}

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Actions -
//------------------------------------------------------------------------------------------

- (IBAction)tappedPump:(id)sender {
    // Increment current number of pumps
    self.pumps++;
    
    // Balloon imploding now
    if (self.pumps == self.positionToImplode || self.pumps >= kMaxPumps) {
        [self implodeBalloon];
        return;
    }

    // Increase the factor a little, proportionally to the device's screen size
    CGFloat increment = (CGRectGetWidth(self.view.frame) / (kMaxPumps * 1000));
    
    // Animate pumping
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseIn animations:^{
        // Inflate slightly more on the x-axis to mimic real balloon
        CGAffineTransform transform = CGAffineTransformScale(self.balloon.transform, 1.005 * (kPumpFactor+increment), (kPumpFactor+increment));
        [self.balloon setTransform:transform];
    } completion:nil];
    
    // Update data
    self.potentialGain += kGainPerPump;
    [self updateEarningLabels];
}

- (IBAction)tappedCollect:(id)sender {
    [self resetBalloon];
}

//------------------------------------------------------------------------------------------
#pragma mark - Data -
//------------------------------------------------------------------------------------------

- (void)implodeBalloon {
    // No gains if balloon implodes
    self.potentialGain = 0;
    [self updateEarningLabels];

    // Prevent user pumping or collecting during animation
    [self.view setUserInteractionEnabled:NO];
    [self.pumpButton setEnabled:NO];
    [self.collectButton setEnabled:NO];
    
    // Explosion animation
    [self.balloon lp_explodeWithCallback:^{
        [self resetBalloon];
        [self.view setUserInteractionEnabled:YES];
        [self.pumpButton setEnabled:YES];
        [self.collectButton setEnabled:YES];
    }];
}

- (void)resetBalloon {
    [self.balloon removeFromSuperview];
    
    // Balloon image
    self.balloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balloon"]];
    
    // Center it, with slight y-axis offset
    self.balloon.center   = self.view.center;
    CGRect balloonFrame   = self.balloon.frame;
    balloonFrame.origin.y -= (CGRectGetHeight(self.potentialGainLabel.frame) + 20.0);
    self.balloon.frame    = balloonFrame;
    
    // Reset balloon size
    [self.balloon setTransform:CGAffineTransformIdentity];
    
    // Add to view, but below all others
    [self.view addSubview:self.balloon];
    [self.view sendSubviewToBack:self.balloon];
    
    // Update data
    self.earnings += self.potentialGain;
    self.potentialGain = 0;
    self.pumps = 0;
    [self pickRandomImplodingStep];
    [self updateEarningLabels];
}

- (void)pickRandomImplodingStep {
    // Select a random position on which to explode balloon, excluding 0 and 1
    self.positionToImplode = arc4random_uniform(kMaxPumps-1) + 2;
}

- (void)updateEarningLabels {
    self.totalEarningsLabel.text = [NSString stringWithFormat:@"Total Earnings: $%.2f", self.earnings];
    self.potentialGainLabel.text = [NSString stringWithFormat:@"Potential Gain: $%.2f", self.potentialGain];
}

@end
