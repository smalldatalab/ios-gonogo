//
//  GOViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "GOViewController.h"
#import "GOConstants.h"

float BUTTON_HEIGHT = 60.f;

@interface GOViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) NSDate *startDate;

@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UILabel *explanationLabel;
@property (strong, nonatomic) UILabel *feedbackLabel;

// Flags
@property (assign, nonatomic) BOOL shouldTap;
@property (assign, nonatomic) BOOL testInProgress;

@end

@implementation GOViewController

//------------------------------------------------------------------------------------------
#pragma mark - View lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Game Explanation
    self.explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 200, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(self.view.frame) / 2)];
    [self.explanationLabel setCenter:self.view.center];
    [self.explanationLabel setText:@"Welcome to the Go/No-Go test. \nOnce you start, you will be presented with a rectangle. When the rectangle turns green, tap anywhere on the screen as quickly as possible. When it turns blue, do not respond at all. The test will take approximately 1 min."];
    [self.explanationLabel setNumberOfLines:0];
    [self.explanationLabel setFont:[UIFont systemFontOfSize:24.f]];
    [self.explanationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.explanationLabel];

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

- (void)startTest {
    
    // Hide button and label
    [UIView animateWithDuration:0.3 animations:^{
        [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
        [self.explanationLabel setHidden:YES];
    }];
    
    // Go through tests
    int laps = 4;
    for (int i=0; i<laps; i++) {
        [self oneLap];
    }
    
    // Wait duration of test before showing controls again
    NSTimeInterval totalLength = laps * (DURATION_WAIT_LAP + DURATION_BLANK_SCREEN + DURATION_FIXATION_CROSS + DURATION_TARGET_ON_SCREEN + 1);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalLength * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Show button and label
        [UIView animateWithDuration:0.3 animations:^{
            [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
            [self.explanationLabel setHidden:NO];
            self.shouldTap = NO;
        }];
    });
}

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
        
        __block UIImageView *imgView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_WAIT_LAP * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Show plus sign for 800ms
            imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus-sign"]];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.center = self.view.center;
            [self.view addSubview:imgView];
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_FIXATION_CROSS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imgView removeFromSuperview];
                
                // Blank screen for 500ms
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_BLANK_SCREEN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    // Go Cue
                    UIView *boxView = [self rectangleView];
                    [self.view addSubview:boxView];
                    
                    // Show color after 100,200,300,400 or 500ms
                    variableDelay = (arc4random() % 5 + 1) / 10.0;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(variableDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        // Change to either blue or green
                        int choice = arc4random() % 2;
                        if (choice == 0) {
                            [boxView setBackgroundColor:[UIColor greenColor]];
                            self.shouldTap = YES;
                            self.startDate = [NSDate date];
                        } else {
                            [boxView setBackgroundColor:[UIColor blueColor]];
                            self.shouldTap = NO;
                        }
                        self.testInProgress = YES;
                        
                        // Hide after 1000ms
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DURATION_TARGET_ON_SCREEN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [boxView removeFromSuperview];
                            [self.feedbackLabel setHidden:YES];
                            self.testInProgress = NO;
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

- (void)tappedScreen {
    
    // Nothing to do if not currently showing a box
    if (!self.testInProgress) {
        return;
    }
    
    // Set feedback label
    if (self.shouldTap) {
        [self.feedbackLabel setText:[NSString stringWithFormat:@"Correct! %0.0f ms", [[NSDate date] timeIntervalSinceDate:self.startDate]*1000.0]];
        [self.feedbackLabel setTextColor:[UIColor colorWithRed:41.0/255 green:128.0/255 blue:185.0/255 alpha:1.0]];
    } else {
        [self.feedbackLabel setText:@"Incorrect"];
        [self.feedbackLabel setTextColor:[UIColor colorWithRed:231.0/255 green:76.0/255 blue:60.0/255 alpha:1.0]];
    }
    
    // Show it briefly
    [self.feedbackLabel setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedbackLabel setHidden:YES];
    });
}

//------------------------------------------------------------------------------------------
#pragma mark - Lazy Instantiation of views -
//------------------------------------------------------------------------------------------

- (UIView*)rectangleView
{
    UIView *boxView           = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    boxView.center            = self.view.center;
    boxView.layer.borderColor = [UIColor blackColor].CGColor;
    boxView.layer.borderWidth = 4.f;
    return boxView;
}

//- (UIImageView*)plusSign
//{
//    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus-sign"]];
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    imgView.center = self.view.center;
//    return imgView;
//}

@end
