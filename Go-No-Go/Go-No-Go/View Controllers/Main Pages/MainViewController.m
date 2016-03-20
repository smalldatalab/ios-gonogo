//
//  ViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 07/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "MainViewController.h"
#import "SVProgressHUD.h"

@interface MainViewController ()

@property (nonatomic, assign) BOOL showedSelfReport;

@end

@implementation MainViewController

//------------------------------------------------------------------------------------------
#pragma mark - View Lifecycle -
//------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Button for profile page
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user"] style:UIBarButtonItemStylePlain target:self action:@selector(openProfile)];
    item.tintColor = [UIColor belizeBlueColor];
    [self.navigationItem setLeftBarButtonItem:item];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Direct users to either square task or balloon game after coming back from self-report
    if (self.showedSelfReport) {
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^{
            NSString *segue = arc4random_uniform(2) == 0 ? @"squareTaskSegue" : @"balloonGameSegue";
            NSString *infoHUD = [segue isEqualToString:@"squareTaskSegue"] ? @"Please complete a Square Task" : @"Please complete a Balloon Game";
            [SVProgressHUD showInfoWithStatus:infoHUD];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:segue sender:self];
            });
        });
        self.showedSelfReport = NO;
    }
    
    // Direct users to self-report
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SVProgressHUD showInfoWithStatus:@"Please complete your daily questions"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"selfReportSegue" sender:self];
            self.showedSelfReport = YES;
        });
    });
}

//------------------------------------------------------------------------------------------
#pragma mark - Actions -
//------------------------------------------------------------------------------------------

- (void)openProfile {
    UINavigationController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"profileNavigationController"];
    [self presentViewController:pvc animated:YES completion:nil];
}

@end
