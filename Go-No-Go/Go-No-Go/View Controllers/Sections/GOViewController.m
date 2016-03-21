//
//  GOViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "GOViewController.h"
#import "AppConstants.h"
#import "OMHClient.h"

static const float BUTTON_HEIGHT = 60.f;
static const int GO_CUE          = 0;
static const int NO_GO_CUE       = 1;

static const int NUMBER_OF_TRIALS = 90; // 30 trials per minute

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
@property (assign, nonatomic) BOOL done;

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
    self.done = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.done = NO;
    
    // Game Explanation
    NSString *instructionsString = @"Welcome to the Square Task.\n\n\nOnce you start, you will be presented with a rectangle. When the rectangle turns green, tap anywhere on the screen as quickly as possible. When it turns blue, do not respond at all. \n\nThe test will take approximately 3 min.";
    NSMutableAttributedString *instructionsText = [[NSMutableAttributedString alloc] initWithString:instructionsString];
    [instructionsText addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:24.0]
                             range:[instructionsString rangeOfString:@"green, tap anywhere on the screen as quickly as possible"]];
    [instructionsText addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:24.0]
                             range:[instructionsString rangeOfString:@"blue, do not respond at all"]];
    [instructionsText addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:24.0]
                             range:[instructionsString rangeOfString:@"3 min"]];
    [self.explanationLabel setAttributedText:instructionsText];

    // Start Button
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
    [self.startButton setTitle:@"Start Square Task" forState:UIControlStateNormal];
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
    self.lapsToDo = NUMBER_OF_TRIALS;
    [self oneLap];
}

/**
 *  Single go/no-go lap (one box showed)
 */
- (void)oneLap {
    
    // Manually cancel dispatch
    if (self.done) {
        return;
    }
    
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
                    NSTimeInterval delay = 0.3;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        // Different probabilities for go and no-go cues
                        // If Go Cue presented, 70% probability of green
                        // If No-Go Cue, only 30% probability
                        int flip = arc4random_uniform(100);
                        
                        // GO
                        if ((cueChoice == GO_CUE && flip > 30) || (cueChoice == NO_GO_CUE && flip < 30)) {
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

                                [self submitResults];
                                [self showResults];
                                
                            // More laps left, loop back
                            } else {
                                [self oneLap];
                            }
                        });
                    });
                });
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
    
    // Show time feedback briefly
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
#pragma mark - DSU Upload -
//------------------------------------------------------------------------------------------

- (void)submitResults {
    if (self.done) {
        return;
    }

    NSDictionary *dataPoint = [self createDataPointForTestResults];
    [[OMHClient sharedClient] submitDataPoint:dataPoint];
}

- (NSDictionary *)createDataPointForTestResults {
    OMHDataPoint *dataPoint = [OMHDataPoint templateDataPoint];
    dataPoint.header.schemaID = [AppConstants schemaID];
    dataPoint.header.acquisitionProvenance = [AppConstants acquisitionProvenance];
    dataPoint.body = [self JSONResultsForDataPoint];
    return dataPoint;
}

- (NSDictionary *)JSONResultsForDataPoint {
    
    int correctResponses      = [self occurrencesOfObject:@YES inArray:self.correctAnswerArray];
    int incorrectResponses    = [self occurrencesOfObject:@NO inArray:self.correctAnswerArray];
    int commissions           = [self numberOfCommissions];
    int ommissions            = [self numberOfOmmissions];
    int correctBlueResponses  = [self countResponsesForCue:NO_GO_CUE andCorrectness:YES];
    int correctGreenResponses = [self countResponsesForCue:GO_CUE andCorrectness:YES];
    double meanAccuracy       = [self occurrencesOfObject:@YES inArray:self.correctAnswerArray] / (double)NUMBER_OF_TRIALS;
    
    // Conform to OMH unit format
    // See: http://www.openmhealth.org/documentation/#/schema-docs/schema-library/schemas/omh_duration-unit-value
    NSDictionary *meanResponseTime  = @{@"unit" : @"ms",
                                        @"value" : @([self averageOfNonZeroValues:self.responseTimeArray])};
    NSDictionary *rangeResponseTime = @{@"unit" : @"ms",
                                        @"value" : @([self rangeOfResponseTimes])};
    NSDictionary *stdDevReponseTime = @{@"unit" : @"ms",
                                        @"value" : @([self standardDeviationOfReponseTimes])};
    
    NSDictionary *time = @{@"date_time" : [OMHDataPoint stringFromDate:[NSDate date]]};
    
    NSDictionary *results = @{@"researcher_code": [[NSUserDefaults standardUserDefaults] objectForKey:kResearcherCode],
                              @"variable_label" : @"Go-no-go",
                              @"effective_time_frame" : time,
                              @"number_of_trials" : @(NUMBER_OF_TRIALS),
                              @"correct_responses" : @(correctResponses),
                              @"incorrect_responses" : @(incorrectResponses),
                              @"correct_blue_responses" : @(correctBlueResponses),
                              @"correct_green_responses" : @(correctGreenResponses),
                              @"commissions" : @(commissions),
                              @"ommissions" : @(ommissions),
                              @"mean_accuracy" : @(meanAccuracy),
                              @"response_time_mean" : meanResponseTime,
                              @"response_time_range" : rangeResponseTime,
                              @"response_time_standard_deviation" : stdDevReponseTime,
                          	  @"correctness_array" : self.correctAnswerArray,
                          	  @"response_times_array" : self.responseTimeArray};
    
    // Divide results into thirds
    NSUInteger len = ceil(self.correctAnswerArray.count / 3);
    NSArray *correctFirstThird  = [self.correctAnswerArray subarrayWithRange:NSMakeRange(0, len)];
    NSArray *correctSecondThird = [self.correctAnswerArray subarrayWithRange:NSMakeRange(len, len)];
    NSArray *correctLastThird   = [self.correctAnswerArray subarrayWithRange:NSMakeRange(2*len, len)];
    len = ceil(self.responseTimeArray.count / 3);
    NSArray *responseTimeFirstThird  = [self.responseTimeArray subarrayWithRange:NSMakeRange(0, len)];
    NSArray *responseTimeSecondThird = [self.responseTimeArray subarrayWithRange:NSMakeRange(len, len)];
    NSArray *responseTimeLastThird   = [self.responseTimeArray subarrayWithRange:NSMakeRange(2*len, len)];

    // Stats in thirds
    int correctResponses_first_third    = [self occurrencesOfObject:@YES inArray:correctFirstThird];
    int correctResponses_second_third   = [self occurrencesOfObject:@YES inArray:correctSecondThird];
    int correctResponses_last_third     = [self occurrencesOfObject:@YES inArray:correctLastThird];
    int incorrectResponses_first_third  = [self occurrencesOfObject:@NO inArray:correctFirstThird];
    int incorrectResponses_second_third = [self occurrencesOfObject:@NO inArray:correctSecondThird];
    int incorrectResponses_last_third   = [self occurrencesOfObject:@NO inArray:correctLastThird];
    double meanAccuracy_first_third     = [self occurrencesOfObject:@YES inArray:correctFirstThird] / (double)(NUMBER_OF_TRIALS / 3);
    double meanAccuracy_second_third    = [self occurrencesOfObject:@YES inArray:correctSecondThird] / (double)(NUMBER_OF_TRIALS / 3);
    double meanAccuracy_last_third      = [self occurrencesOfObject:@YES inArray:correctLastThird] / (double)(NUMBER_OF_TRIALS / 3);
    NSDictionary *meanResponseTime_first_third = @{@"unit" : @"ms",
                                    @"value" : @([self averageOfNonZeroValues:responseTimeFirstThird])};
    NSDictionary *meanResponseTime_second_third = @{@"unit" : @"ms",
                                    @"value" : @([self averageOfNonZeroValues:responseTimeSecondThird])};
    NSDictionary *meanResponseTime_last_third = @{@"unit" : @"ms",
                                    @"value" : @([self averageOfNonZeroValues:responseTimeLastThird])};

    // Add them to results
    NSDictionary *additionalStats = @{@"correct_responses_first_third" : @(correctResponses_first_third),
                                      @"correct_responses_second_third" : @(correctResponses_second_third),
                                      @"correct_responses_last_third" : @(correctResponses_last_third),
                                      @"incorrect_responses_first_third" : @(incorrectResponses_first_third),
                                      @"incorrect_responses_second_third" : @(incorrectResponses_second_third),
                                      @"incorrect_responses_last_third" : @(incorrectResponses_last_third),
                                      @"mean_accuracy_first_third" : @(meanAccuracy_first_third),
                                      @"mean_accuracy_second_third" : @(meanAccuracy_second_third),
                                      @"mean_accuracy_last_third" : @(meanAccuracy_last_third),
                                      @"response_time_mean_first_third" : meanResponseTime_first_third,
                                      @"response_time_mean_second_third" : meanResponseTime_second_third,
                                      @"response_time_mean_last_third" : meanResponseTime_last_third};
    
    // Return combination
    NSMutableDictionary *finalResults = [results mutableCopy];
    [finalResults addEntriesFromDictionary:additionalStats];

    return finalResults;
}

//------------------------------------------------------------------------------------------
#pragma mark - Helper Methods -
//------------------------------------------------------------------------------------------

// Count occurrences of object in an array
- (int)occurrencesOfObject:(id)object inArray:(NSArray*)array
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

- (double)rangeOfResponseTimes {
    // Remove zeros
    NSMutableArray *nonZeroResponseTimes = [[NSMutableArray alloc] initWithArray:self.responseTimeArray copyItems:YES];
    [nonZeroResponseTimes removeObjectIdenticalTo:@(0.0)];

    // In case not enough data points
    if ([nonZeroResponseTimes count] < 2) {
        return 0.0;
    }

    // Find min & max values
    float xmax = -MAXFLOAT;
    float xmin = MAXFLOAT;
    for (NSNumber *num in nonZeroResponseTimes) {
        float x = num.floatValue;
        if (x < xmin) xmin = x;
        if (x > xmax) xmax = x;
    }
    
    return xmax - xmin;
}

- (double)standardDeviationOfReponseTimes {
    // Remove zeros
    NSMutableArray *nonZeroResponseTimes = [[NSMutableArray alloc] initWithArray:self.responseTimeArray copyItems:YES];
    [nonZeroResponseTimes removeObjectIdenticalTo:@(0.0)];
    
    if (nonZeroResponseTimes.count > 1) {
        NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:nonZeroResponseTimes]]];
        return [[expression expressionValueWithObject:nil context:nil] doubleValue];
    }
    
    return 0.0;
}

- (int)countResponsesForCue: (int)cue andCorrectness:(BOOL)correct {
    int total = 0;

    for (int i = 0; i < self.cues.count; i++) {
        int current_cue          = [[self.cues objectAtIndex:i] intValue];
        BOOL current_correctness = [[self.correctAnswerArray objectAtIndex:i] boolValue];
        
        if (current_cue == cue && current_correctness == correct) {
            total++;
        }
    }
    return total;
}

// Hit when should not: Blue incorrect
- (int)numberOfCommissions {
    return [self countResponsesForCue:NO_GO_CUE andCorrectness:NO];
}

// No hit when should: Green incorrect
- (int)numberOfOmmissions {
    return [self countResponsesForCue:GO_CUE andCorrectness:NO];
}

@end
