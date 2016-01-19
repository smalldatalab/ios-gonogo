//
//  GOViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "GOViewController.h"
#import "AppConstants.h"
#import "UIColor+Additions.h"

static const float BUTTON_HEIGHT = 60.f;
static const int GO_CUE          = 0;
static const int NO_GO_CUE       = 1;

static const int NUMBER_OF_TRIALS = 15;

@interface GOViewController ()

// UI elements
@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UILabel *feedbackLabel;
@property (strong, nonatomic) UITextView *resultsTextView;

// Flags
@property (assign, nonatomic) BOOL shouldTap;
@property (assign, nonatomic) BOOL testInProgress;
@property (assign, nonatomic) int lapsToDo;

// Track user reactions during tests
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) NSDate *startDate;

// Track results
@property (strong, nonatomic) NSMutableArray *cues;
@property (strong, nonatomic) NSMutableArray *correctAnswerArray;
@property (strong, nonatomic) NSMutableArray *responseTimeArray;

@end

@implementation GOViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Game Explanation
    [self.explanationLabel setText:@"Welcome to the Go/No-Go test. \n\n\nOnce you start, you will be presented with a rectangle. When the rectangle turns green, tap anywhere on the screen as quickly as possible. When it turns blue, do not respond at all. \n\nThe test will take approximately 1 min."];

    // Start Button
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
    [self.startButton setTitle:@"Start Go/No-Go" forState:UIControlStateNormal];
    [self.startButton setBackgroundColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]]; //rgba(52, 73, 94,1.0)
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    // Feedback label
    self.feedbackLabel = [[UILabel alloc] initWithFrame:self.startButton.frame];
    [self.feedbackLabel setNumberOfLines:1];
    [self.feedbackLabel setTextAlignment:NSTextAlignmentCenter];
    [self.feedbackLabel setHidden:YES];
    [self.view addSubview:self.feedbackLabel];
    
    // Tap gesture
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScreen)];
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//------------------------------------------------------------------------------------------
#pragma mark - Test Lifecycle -
//------------------------------------------------------------------------------------------

/**
 *  Configure and Start Go/No-Go test
 */
- (void)startTest {
    
    // Results
    self.correctAnswerArray = [[NSMutableArray alloc] init];
    self.responseTimeArray  = [[NSMutableArray alloc] init];
    self.cues               = [[NSMutableArray alloc] init];
    
    // Hide button and label
    [UIView animateWithDuration:0.3 animations:^{
        [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
        [self.explanationLabel setHidden:YES];
        
        // Hide results textview if visible
        if (self.resultsTextView) {
            CGRect newFrame            = self.resultsTextView.frame;
            newFrame.origin.y          = CGRectGetMaxY(self.view.frame) + 20;
            self.resultsTextView.frame = newFrame;
        }
    }];
    
    // Go through tests
    int laps = self.lapsToDo = NUMBER_OF_TRIALS;
    for (int i=0; i<laps; i++) {
        [self oneLap];
    }
    
    // Wait total duration of test before showing controls again
    NSTimeInterval totalLength = laps * (DURATION_WAIT_LAP + DURATION_BLANK_SCREEN + DURATION_FIXATION_CROSS + DURATION_TARGET_ON_SCREEN + 0.8);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalLength * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Show button and label
        [UIView animateWithDuration:0.3 animations:^{
            [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
            [self.explanationLabel setHidden:NO];
            self.shouldTap = NO;
        }];
    });
}

/**
 *  Single go/no-go lap (one box showed)
 */
- (void)oneLap {
    
    // Private serial queue to preserve presentation ordering
    static dispatch_queue_t goQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        goQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    });
    
    __block double variableDelay; // Store the random delay for the cued target to be displayed
    // Enter queue
    dispatch_async(goQueue, ^{
        
        // Suspend queue
        dispatch_suspend(goQueue);
        
        // Show plus sign for 800ms
        __block UIImageView *imgView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_WAIT_LAP * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus-sign"]];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.center = self.view.center;
            [self.view addSubview:imgView];
        
            // Remove plus sign
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_FIXATION_CROSS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imgView removeFromSuperview];
                
                // Blank screen for 500ms
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_BLANK_SCREEN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    UIView *cueBox;
                    // Flip a coin on go or no-go cue
                    int cueChoice = arc4random() % 2;
                    if (cueChoice == GO_CUE) {
                        cueBox = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
                    } else {
                        cueBox = [[UIView alloc] initWithFrame:CGRectMake(200, 100, 100, 200)];
                    }
                    cueBox.center            = self.view.center;
                    cueBox.layer.borderColor = [UIColor blackColor].CGColor;
                    cueBox.layer.borderWidth = 4.f;
                    [self.view addSubview:cueBox];
                    
                    // Show color after 100,200,300,400 or 500ms
                    variableDelay = (arc4random() % 5 + 1) / 10.0;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(variableDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        // Different probabilities for go and no-go cues
                        // If Go Cue presented, 80% probability of green
                        // If No-Go Cue, only 20% probability
                        int flip = arc4random_uniform(100);
                        
                        // GO
                        if ((cueChoice == GO_CUE && flip > 20) || (cueChoice == NO_GO_CUE && flip < 20)) {
                            [cueBox setBackgroundColor:[UIColor VALID_COLOR]];
                            [self.cues addObject:[NSNumber numberWithInt:GO_CUE]];
                            
                            // Setup results array
                            [self.correctAnswerArray addObject:@NO];   // Assume incorrect
                            [self.responseTimeArray addObject:@0.0];    // and 0ms in reaction time
                            self.shouldTap = YES;
                            self.startDate = [NSDate date];
                            
                        // NO-GO
                        } else {
                            [cueBox setBackgroundColor:[UIColor INVALID_COLOR]];
                            [self.cues addObject:[NSNumber numberWithInt:NO_GO_CUE]];
                            
                            // Setup results array
                            [self.correctAnswerArray addObject:@YES];   // Assume correct
                            [self.responseTimeArray addObject:@0.0];    // and 0ms in reaction time
                            self.shouldTap = NO;
                        }
                        // Set flag for test in progress
                        self.testInProgress = YES;
                        
                        // Hide after 1000ms
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_TARGET_ON_SCREEN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [cueBox removeFromSuperview];
                            [self.feedbackLabel setHidden:YES];
                            self.testInProgress = NO;
                            self.lapsToDo -= 1;
                            
                            // Done with the tests
                            if (self.lapsToDo == 0) {
                                // Show results
                                [self showResults];
                            }
                        });
                    });
                });
            });
        });
        
        // Resume queue
        const NSTimeInterval totalWait = DURATION_WAIT_LAP + DURATION_FIXATION_CROSS + DURATION_BLANK_SCREEN + variableDelay + DURATION_TARGET_ON_SCREEN + 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalWait * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            dispatch_resume(goQueue);
        });
    });
}

/**
 *  Handle Tap Gestures during test
 */
- (void)tappedScreen {
    
    // Nothing to do if not currently showing a box
    if (!self.testInProgress) {
        return;
    }
    
    // Prevent from re-tapping
    self.testInProgress = NO;
    
    // Correct - record speed
    if (self.shouldTap) {
        
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.startDate] * 1000.0;
        
        // Feedback label
        [self.feedbackLabel setText:[NSString stringWithFormat:@"Correct! %0.0f ms", time]];
        [self.feedbackLabel setTextColor:[UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1.0]];

        // Record time
        [self.responseTimeArray removeLastObject];
        [self.responseTimeArray addObject:[NSNumber numberWithDouble:time]];
        
        [self.correctAnswerArray removeLastObject];
        [self.correctAnswerArray addObject:@YES];
        
    // Wrong
    } else {
        
        // Feedback label
        [self.feedbackLabel setText:@"Incorrect"];
        [self.feedbackLabel setTextColor:[UIColor colorWithRed:231.0/255 green:76.0/255 blue:60.0/255 alpha:1.0]];
        
        // Record wrong answer
        [self.correctAnswerArray removeLastObject];
        [self.correctAnswerArray addObject:@NO];
    }
    
    // Show it briefly
    [self.feedbackLabel setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedbackLabel setHidden:YES];
    });
}

/**
 *  Show results to the user
 */
- (void)showResults {
    
    // Create a textview to display results, and center it within view
    self.resultsTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,
                                                                        CGRectGetWidth(self.view.frame) - 40,
                                                                        CGRectGetHeight(self.view.frame) / 1.5)];
    self.resultsTextView.center                 = self.view.center;
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
    self.resultsTextView.text = [NSString stringWithFormat:@"Correct Answers: %d\n\n"
                                 "Incorrect Answers: %d\n\n"
                                 "Mean Response Time: %.0f msec\n\n"
                                 "Number of Commissions (hit when should not): %d\n\n"
                                 "Number of Ommissions (not hit when should): %d",
                                 [self occurrencesOfObject:@YES inArray:self.correctAnswerArray],
                                 [self occurrencesOfObject:@NO inArray:self.correctAnswerArray],
                                 [self averageOfNonZeroValues:self.responseTimeArray],
                                 [self numberOfCommissions],
                                 [self numberOfOmmissions]];
    
    // Drop it below to animate it up
    CGRect newFrame   = self.resultsTextView.frame;
    newFrame.origin.y = CGRectGetMaxY(self.view.frame) + 20;
    [self.resultsTextView setFrame:newFrame];
    [self.view addSubview:self.resultsTextView];
    [self.view bringSubviewToFront:self.resultsTextView];
    [UIView animateWithDuration:0.5 animations:^{
        [self.resultsTextView setCenter:self.view.center];
    }];
}

//------------------------------------------------------------------------------------------
#pragma mark - Helper Methods -
//------------------------------------------------------------------------------------------

// Count occurrences of object in an array
- (int)occurrencesOfObject:(id)object inArray:(NSMutableArray*)array
{
    NSCountedSet *set = [[NSCountedSet alloc] initWithArray:array];
    return (int)[set countForObject:object];
}

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

// Commissions: Hit when should not
- (int)numberOfCommissions
{
    int commissions = 0;
    for (int i=0; i<self.cues.count; i++) {
        int cue = [[self.cues objectAtIndex:i] intValue];
        BOOL correct = [[self.correctAnswerArray objectAtIndex:i] boolValue];
        if (cue == NO_GO_CUE && !correct) {
            commissions += 1;
        }
    }
    return commissions;
}

// Omissions: Do not hit when should
- (int)numberOfOmmissions
{
    int ommissions = 0;
    for (int i=0; i<self.cues.count; i++) {
        int cue = [[self.cues objectAtIndex:i] intValue];
        BOOL correct = [[self.correctAnswerArray objectAtIndex:i] boolValue];
        if (cue == GO_CUE && !correct) {
            ommissions += 1;
        }
    }
    return ommissions;
}

@end
