//
//  GOViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "GOViewController.h"

float BUTTON_HEIGHT = 60.f;

@interface GOViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;

@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UILabel *explanationLabel;

@end

@implementation GOViewController

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
    [self.explanationLabel setText:@"Welcome to the Go/No-Go test. \nOnce you start, you will be presented with a rectangle. When the rectangle turns green, press as soon as possible. When it turns blue, do not respond at all. The test will take 1 min."];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startTest {
    
    // Hide button and label
    [UIView animateWithDuration:0.3 animations:^{
        [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
        [self.explanationLabel setHidden:YES];
    }];
    
    // Show plus sign for 800ms
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus-sign"]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.center = self.view.center;
    [self.view addSubview:imgView];
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imgView removeFromSuperview];
            
            // Blank screen for 500ms
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // Go Cue
                UIView *boxView           = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
                boxView.center            = self.view.center;
                boxView.layer.borderColor = [UIColor blackColor].CGColor;
                boxView.layer.borderWidth = 1.f;
                [self.view addSubview:boxView];
                
                // Show color after 100,200,300,400 or 500ms
                double delay = (arc4random() % 5 + 1) / 10.0;
                NSLog(@"%f", delay);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    // Change to either blue or green
                    int choice = arc4random() % 2;
                    if (choice == 0) {
                        [boxView setBackgroundColor:[UIColor greenColor]];
                    } else {
                        [boxView setBackgroundColor:[UIColor blueColor]];
                    }
           
                    // Hide after 1000ms
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [boxView removeFromSuperview];
                        
                        // Wait 700ms to start again
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            // Show button and label
                            [UIView animateWithDuration:0.1 animations:^{
                                [self.startButton setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
                                [self.explanationLabel setHidden:NO];
                            }];
                            
                        });
                    });
                    
                });
                
            });
        });
    
}

@end
