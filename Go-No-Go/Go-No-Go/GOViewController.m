//
//  GOViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "GOViewController.h"

@interface GOViewController ()

@end

@implementation GOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [self firstRound];
}

- (void)firstRound {
    
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
                            // ...
                        });
                    });
                    
                });
                
            });
        });
    
}

@end
