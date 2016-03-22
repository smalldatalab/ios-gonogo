//
//  BalloonViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 14/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "BalloonViewController.h"
#import "UIView+Explode.h"
#import "AppConstants.h"
#import "OMHClient.h"

static CGFloat const kPumpFactor  = 1.1;
static CGFloat const kGainPerPump = 0.25;
static NSInteger const kMaxPumps  = 12;
static NSInteger const kNumBalloons = 15;
static const float BUTTON_HEIGHT = 60.f;

@interface BalloonViewController ()

// UI
@property (nonatomic, strong) UIImageView *balloon;
@property (nonatomic, strong) IBOutlet UILabel *potentialGainLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalEarningsLabel;
@property (nonatomic, strong) IBOutlet UIButton *pumpButton;
@property (nonatomic, strong) IBOutlet UIButton *collectButton;
@property (nonatomic, strong) UITextView *resultsTextView;
@property (strong, nonatomic) UILabel *explanationLabel;
@property (strong, nonatomic) UIButton *startButton;

// Test Variables
@property (nonatomic, assign) double earnings;
@property (nonatomic, assign) double potentialGain;
@property (nonatomic, assign) int pumps;
@property (nonatomic, assign) int currentBalloon;

// Data Recording
@property (nonatomic, strong) NSMutableArray *pumpsPerBalloon;
@property (nonatomic, strong) NSMutableArray *pumpsAfterExplode;
@property (nonatomic, strong) NSMutableArray *pumpsAfterNoExplode;
@property (nonatomic, assign) BOOL lastBalloonExploded;
@property (nonatomic, assign) int numberOfExplosions;
@property (nonatomic, strong) NSDate *startGameDate;
@property (nonatomic, strong) NSMutableArray *completionTimes;

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
    self.numberOfExplosions = 0;
    self.currentBalloon = 1;
    self.lastBalloonExploded = NO;
    self.pumpsPerBalloon = [[NSMutableArray alloc] init];
    self.pumpsAfterExplode = [[NSMutableArray alloc] init];
    self.pumpsAfterNoExplode = [[NSMutableArray alloc] init];
    self.completionTimes = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Set up the balloon on the screen
    [self resetBalloon];
    [self showInstructions];
}

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showInstructions {
    
    // Hide UI
    for (UIView *view in @[self.potentialGainLabel, self.totalEarningsLabel, self.pumpButton, self.collectButton, self.balloon]) {
        [view setHidden:YES];
    }
    
    // Show explanation
    self.explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70,
                                                                      CGRectGetWidth(self.view.frame) - 40,
                                                                      CGRectGetHeight(self.view.frame) - 70 - BUTTON_HEIGHT)];
    // Game Explanation
    NSString *instructionsString = @"Welcome to the Balloon Game.\n\nYour goal for this game is to make as much money as possible by inflating the balloons. To play, tap the pump button to inflate the balloon and earn 25 cents for each pump. To collect your money for each balloon, hit the collect button. But remember, the more you pump the balloon, the greater chance of it bursting. The max amount you can win per balloon is $2.50. When it bursts, you get no money for that balloon. Your goal is to earn as much possible over the 15 balloons.";
    NSMutableAttributedString *instructionsText = [[NSMutableAttributedString alloc] initWithString:instructionsString];
    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0];
    [instructionsText addAttribute:NSFontAttributeName value:boldFont range:[instructionsString rangeOfString:@"pump button to inflate the balloon and earn 25 cents for each pump"]];
    [instructionsText addAttribute:NSFontAttributeName value:boldFont range:[instructionsString rangeOfString:@"collect button"]];
    [instructionsText addAttribute:NSFontAttributeName value:boldFont range:[instructionsString rangeOfString:@"15 balloons"]];
    [instructionsText addAttribute:NSFontAttributeName value:boldFont range:[instructionsString rangeOfString:@"per balloon"]];
    [self.explanationLabel setFont:regularFont];
    [self.explanationLabel setAttributedText:instructionsText];
    [self.explanationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.explanationLabel setNumberOfLines:0];
    [self.explanationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.explanationLabel setMinimumScaleFactor:0.5];
    [self.view addSubview:self.explanationLabel];
    
    // Start Button
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setBackgroundColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(hideInstructions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
}

- (void)hideInstructions {
    // Hide start button
    [UIView animateWithDuration:0.3 animations:^{
        [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
        [self.explanationLabel setAlpha:0];
    } completion:^(BOOL finished) {
        [self.startButton removeFromSuperview];
        [self.explanationLabel removeFromSuperview];
        
        // Start stopwatch
        self.startGameDate = [NSDate date];
    
        // Hide UI
        for (UIView *view in @[self.potentialGainLabel, self.totalEarningsLabel, self.pumpButton, self.collectButton, self.balloon]) {
            [view setHidden:NO];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Game Actions -
//------------------------------------------------------------------------------------------

- (IBAction)tappedPump:(id)sender {
    // Limit number of balloons
    if (self.currentBalloon > kNumBalloons) {
        return;
    }
    
    // Increment current number of pumps
    self.pumps++;
    
    // Balloon imploding now
    if ([self shouldImplodeNow] || self.pumps >= kMaxPumps) {
        [self implodeBalloon];
        return;
    }

    // Increase the factor a little, proportionally to the device's screen size
    CGFloat increment = (CGRectGetWidth(self.view.frame) / (kMaxPumps * 1000));
    
    // Animate pumping
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseIn animations:^{
        // Inflate slightly more on the x-axis to mimic real balloon
        CGAffineTransform transform = CGAffineTransformScale(self.balloon.transform,
                                                             1.005 * (kPumpFactor+increment),
                                                             (kPumpFactor+increment));
        [self.balloon setTransform:transform];
    } completion:nil];
    
    // Update data
    self.potentialGain += kGainPerPump;
    [self updateEarningLabels];
}

- (IBAction)tappedCollect:(id)sender {
    [self.completionTimes addObject:@([[NSDate date] timeIntervalSinceDate:self.startGameDate] - [self sumOfAllElementsInArray:self.completionTimes])];
    self.currentBalloon++; // Move to next balloon
    self.lastBalloonExploded = NO; // Set flag
    [self resetBalloon];
}

- (double)sumOfAllElementsInArray:(NSArray*)array {
    double output = 0.0;
    for (NSNumber *num in array) {
        output += [num doubleValue];
    }
    return output;
}

//------------------------------------------------------------------------------------------
#pragma mark - Data -
//------------------------------------------------------------------------------------------

- (void)implodeBalloon {
    // No gains if balloon implodes
    self.potentialGain = 0;
    [self.completionTimes addObject:@([[NSDate date] timeIntervalSinceDate:self.startGameDate] - [self sumOfAllElementsInArray:self.completionTimes])];
    self.currentBalloon++; // Move to next balloon
    self.numberOfExplosions++;
    self.lastBalloonExploded = YES; // Set flag
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

    // Record Data after first balloon
    if (self.currentBalloon > 1) {
        [self.pumpsPerBalloon addObject:@(self.pumps)];
        if (self.lastBalloonExploded) {
            [self.pumpsAfterExplode addObject:@(self.pumps)];
        } else {
            [self.pumpsAfterNoExplode addObject:@(self.pumps)];
        }
    }
    
    self.pumps = 0;
    [self updateEarningLabels];
    
    // Done with the game, show results and upload to DSU
    if (self.currentBalloon > kNumBalloons) {
        [self submitResults];
        [self showResults];
    }
}

- (BOOL)shouldImplodeNow {
    // Don't burst on first pump
    if (self.pumps <= 1) {
        return NO;
    }
    
    // Probability of burst: 1-11, 1-10, 1-9, etc.
    int maxValue = (int)(kMaxPumps-self.pumps+1);
    return (arc4random_uniform(maxValue) + 1) == 1;
}

- (void)updateEarningLabels {
    // If some balloons are left, show the count, else only show earnings
    if (self.currentBalloon <= kNumBalloons) {
        self.totalEarningsLabel.text = [NSString stringWithFormat:@"Balloon %d out of 15.\nTotal Earnings: $%.2f", self.currentBalloon, self.earnings];
    } else {
        self.totalEarningsLabel.text = [NSString stringWithFormat:@"Total Earnings: $%.2f", self.earnings];
    }
    self.potentialGainLabel.text = [NSString stringWithFormat:@"Potential Gain: $%.2f", self.potentialGain];
}

//------------------------------------------------------------------------------------------
#pragma mark - Post-Game -
//------------------------------------------------------------------------------------------

- (void)submitResults {
    NSDictionary *dataPoint = [self createDataPointForTestResults];
    [[OMHClient sharedClient] submitDataPoint:dataPoint];
}

- (NSDictionary *)createDataPointForTestResults {
    OMHDataPoint *dataPoint = [OMHDataPoint templateDataPoint];
    dataPoint.header.schemaID = [AppConstants BARTschemaID];
    dataPoint.header.acquisitionProvenance = [AppConstants acquisitionProvenance];
    dataPoint.body = [self JSONResultsForDataPoint];
    return dataPoint;
}

- (NSDictionary *)JSONResultsForDataPoint {
    // Divide results into thirds
    NSUInteger len = ceil(self.pumpsPerBalloon.count / 3);
    NSArray *firstThird = [self.pumpsPerBalloon subarrayWithRange:NSMakeRange(0, len)];
    NSArray *secondThird = [self.pumpsPerBalloon subarrayWithRange:NSMakeRange(len, len)];
    NSArray *lastThird = [self.pumpsPerBalloon subarrayWithRange:NSMakeRange(2*len, len)];
    
    // Global stats
    double meanPumps = [self averageOfNonZeroValues:self.pumpsPerBalloon];
    int rangePumps = [self rangeOfValues:self.pumpsPerBalloon];
    double stdDevPumps = [self standardDeviationOfValues:self.pumpsPerBalloon];
    
    // Thirds stats

    // 1/3
    double meanPumps1 = [self averageOfNonZeroValues:firstThird];
    int rangePumps1 = [self rangeOfValues:firstThird];
    double stdDevPumps1 = [self standardDeviationOfValues:firstThird];
    // 2/3
    double meanPumps2 = [self averageOfNonZeroValues:secondThird];
    int rangePumps2 = [self rangeOfValues:secondThird];
    double stdDevPumps2 = [self standardDeviationOfValues:secondThird];
    // 3/3
    double meanPumps3 = [self averageOfNonZeroValues:lastThird];
    int rangePumps3 = [self rangeOfValues:lastThird];
    double stdDevPumps3 = [self standardDeviationOfValues:lastThird];
    
    // Current time
    NSDictionary *time = @{@"date_time" : [OMHDataPoint stringFromDate:[NSDate date]]};
    
    // Time to complete whole task
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startGameDate];
    NSDictionary *completionTime  = @{@"unit" : @"sec",
                                        @"value" : @(interval)};
    
    NSDictionary *results = @{@"researcher_code": [[NSUserDefaults standardUserDefaults] objectForKey:kResearcherCode],
                              @"variable_label" : @"BART",
                              @"effective_time_frame" : time,
                              @"completion_time" : completionTime,
                              @"pumps_mean" : @(meanPumps),
                              @"pumps_range" : @(rangePumps),
                              @"pumps_standard_deviation" : @(stdDevPumps),
                              @"number_of_explosions" : @(self.numberOfExplosions),
                              @"number_of_balloons" : @(kNumBalloons),
                              @"total_gains" : @(self.earnings),
                              @"max_pumps_per_balloon" : @(kMaxPumps),
                              @"earning_increment_per_pump" : @(kGainPerPump),
                              @"mean_pumps_after_explode" : @((int)[self averageOfNonZeroValues:self.pumpsAfterExplode]),
                              @"mean_pumps_after_no_explode" : @((int)[self averageOfNonZeroValues:self.pumpsAfterNoExplode]),
                              @"pumps_mean_first_third" : @(meanPumps1),
                              @"pumps_mean_second_third" : @(meanPumps2),
                              @"pumps_mean_last_third" : @(meanPumps3),
                              @"pumps_range_first_third" : @(rangePumps1),
                              @"pumps_range_second_third" : @(rangePumps2),
                              @"pumps_range_last_third" : @(rangePumps3),
                              @"pumps_standard_deviation_first_third" : @(stdDevPumps1),
                              @"pumps_standard_deviation_second_third" : @(stdDevPumps2),
                              @"pumps_standard_deviation_last_third" : @(stdDevPumps3),
                              @"pumps_per_balloon" : self.pumpsPerBalloon,
                              @"time_per_balloon": self.completionTimes};

    return results;
}

/**
 *  Show results to the user
 */
- (void)showResults {
    
    // Prevent tapping buttons
    [self.collectButton setEnabled:NO];
    [self.pumpButton setEnabled:NO];
    
    // Create a textview to display results, and center it within view
    self.resultsTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 70,
                                                                        CGRectGetWidth(self.view.frame) - 40,
                                                                        CGRectGetHeight(self.view.frame) / 1.2)];
    // Fix for centering view
    CGPoint center = self.view.center;
    center.y       = CGRectGetMidY(self.view.frame) + CGRectGetHeight(self.navigationController.navigationBar.frame);
    self.resultsTextView.center                 = center;
    self.resultsTextView.font                   = [UIFont systemFontOfSize:18];
    self.resultsTextView.editable               = NO;
    self.resultsTextView.scrollEnabled          = NO;
    self.resultsTextView.userInteractionEnabled = NO;
    self.resultsTextView.clipsToBounds          = NO;
    self.resultsTextView.layer.cornerRadius     = 10;
    self.resultsTextView.layer.borderColor      = [UIColor blackColor].CGColor;
    self.resultsTextView.layer.borderWidth      = 0.3;
    self.resultsTextView.layer.shadowColor      = [UIColor blackColor].CGColor;
    self.resultsTextView.layer.shadowOpacity    = 1.0;
    self.resultsTextView.layer.shadowRadius     = 5.0;
    self.resultsTextView.layer.shadowOffset     = CGSizeMake(1, 3);
    
    // Results
    self.resultsTextView.text = [NSString stringWithFormat:@"Average Pumps per Balloon: %.1f\n\n"
                                 "Total Earnings: $%.2f\n\n"
                                 "Number of Balloon Explosions: %d\n\n",
                                 [self averageOfNonZeroValues:self.pumpsPerBalloon],
                                 self.earnings,
                                 self.numberOfExplosions];
    
    // Drop it below to animate it up
    CGRect newFrame   = self.resultsTextView.frame;
    newFrame.origin.y = CGRectGetMaxY(self.view.frame) + 20;
    [self.resultsTextView setFrame:newFrame];
    [self.view addSubview:self.resultsTextView];
    [self.view bringSubviewToFront:self.resultsTextView];
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint center = self.view.center;
        center.y       = CGRectGetMidY(self.view.frame) + CGRectGetHeight(self.navigationController.navigationBar.frame);
        [self.resultsTextView setCenter:center];
    }];
}

//------------------------------------------------------------------------------------------
#pragma mark - Helper Methods -
//------------------------------------------------------------------------------------------

// Return mean of values in array, excluding 0's
- (double)averageOfNonZeroValues:(NSArray*)array
{
    double total = 0.0;
    int count = 0;
    for (NSNumber *value in array) {
        if (value > 0) {
            total += [value doubleValue];
            count += 1;
        }
    }
    return total / count;
}

- (int)rangeOfValues:(NSArray*)array {
    if (array.count < 2) {
        return 0;
    }
    
    // Find min & max values
    int xmax = -INT_MAX;
    int xmin = INT_MAX;
    for (NSNumber *num in array) {
        int x = num.intValue;
        if (x < xmin) xmin = x;
        if (x > xmax) xmax = x;
    }
    return xmax - xmin;
}

- (double)standardDeviationOfValues:(NSArray*)array {
    NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:array]]];
    return [[expression expressionValueWithObject:nil context:nil] doubleValue];
}

@end
