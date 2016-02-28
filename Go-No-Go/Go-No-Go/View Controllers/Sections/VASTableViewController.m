//
//  VASTableViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 27/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "VASTableViewController.h"
#import "VASTableViewCell.h"
#import "ImpulsivityQuestions.h"
#import "OMHClient.h"
#import "AppConstants.h"

NSString* const kSliderCellReuseIdentifier = @"kSliderCellReuseIdentifier";

@interface VASTableViewController () <VASTableViewCellProtocol>

@property (strong, nonatomic) NSArray<NSString*> *questionsArray;
@property (strong, nonatomic) NSMutableArray<NSNumber*> *answersArray;

@property (nonatomic, assign) BOOL hasAnsweredAQuestion;
@property (nonatomic, strong) NSString *testType;

@end

@implementation VASTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Done button
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
    
    // Need to do baseline first
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kHAS_COMPLETED_BASELINE]) {
        self.questionsArray = [ImpulsivityQuestions baselineVASQuestions];
        self.testType = @"baseline";
    }
    
    // Baseline done
    else {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
        NSInteger currentHour = [components hour];

        // Morning
        if (currentHour < 12) {
            self.questionsArray = [ImpulsivityQuestions dailyVASQuestions];
            self.testType = @"morning";
        }
        // Evening
        else if (currentHour > 19) {
            self.questionsArray = [ImpulsivityQuestions dailyVASQuestions];
            self.testType = @"evening";
        }
        // Else baseline
        else {
            self.questionsArray = [ImpulsivityQuestions baselineVASQuestions];
            self.testType = @"baseline";
        }
    }

    // Fill answers with 0s
    self.answersArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.questionsArray.count; i++) {
        [self.answersArray addObject:@5];
    }
    
    // Tableview
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Register local notifications
    [self requestNotifications];
}

- (void)requestNotifications {
    UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;
    
    // Already enabled or denied
    if ((settings.types & UIUserNotificationTypeAlert) || [[NSUserDefaults standardUserDefaults] boolForKey:kHasRequestedPermissionKey]) {
        return;
    }
    
    NSString *title = @"Reminder Permissions";
    NSString *message = @"To deliver reminders, Pulsus needs permission to display notifications. Please allow notifications for Pulsus.";
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasRequestedPermissionKey];
    
    // Notify the user then register local notifications
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Default 'OK' action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [self updateReminders];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateReminders {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [components setHour: 10];
    [components setMinute: 0];
    [components setSecond: 0];
    [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
    NSDate *morningTime = [calendar dateFromComponents:components];
    
    [components setHour:19];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *eveningTime = [calendar dateFromComponents:components];
    
    // Create morning notification
    UILocalNotification *morningNotification = [[UILocalNotification alloc] init];
    morningNotification.alertBody      = @"Daily reminder to complete your self-report.";
    morningNotification.fireDate       = morningTime;
    morningNotification.repeatInterval = NSCalendarUnitDay;
    morningNotification.soundName      = UILocalNotificationDefaultSoundName;
    morningNotification.timeZone       = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:morningNotification];
    
    // Create evening notification
    UILocalNotification *eveningNotification = [[UILocalNotification alloc] init];
    eveningNotification.alertBody      = @"Daily reminder to complete your self-report.";
    eveningNotification.fireDate       = eveningTime;
    eveningNotification.repeatInterval = NSCalendarUnitDay;
    eveningNotification.soundName      = UILocalNotificationDefaultSoundName;
    eveningNotification.timeZone       = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:eveningNotification];
}

- (void)dismissView {
    
    // If user has answered at least a question, save the results to DSU
    if (self.hasAnsweredAQuestion) {
        [self submitResults];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHAS_COMPLETED_BASELINE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)questionAtIndexPath:(NSIndexPath *)indexPath answeredWith:(NSNumber *)answer {
    self.hasAnsweredAQuestion = YES;
    [self.answersArray setObject:answer atIndexedSubscript:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.questionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VASTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSliderCellReuseIdentifier forIndexPath:indexPath];
    [cell.titleLabel setText:[self.questionsArray objectAtIndex:indexPath.row]];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.slider.value = [[self.answersArray objectAtIndex:indexPath.row] floatValue];
    
    [cell updateValueLabel];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (![self.testType isEqualToString:@"baseline"]) {
        return [ImpulsivityQuestions baselineVASInstructions];
    } else {
        return [ImpulsivityQuestions dailyVASInstructions];
    }
}

#pragma mark - Data Upload

- (void)submitResults {
    NSDictionary *dataPoint = [self createDataPointForTestResults];
    [[OMHClient sharedClient] submitDataPoint:dataPoint];
}

- (NSDictionary *)createDataPointForTestResults {
    OMHDataPoint *dataPoint = [OMHDataPoint templateDataPoint];
    dataPoint.header.schemaID = [AppConstants VASschemaID];
    dataPoint.header.acquisitionProvenance = [AppConstants acquisitionProvenance];
    dataPoint.body = [self JSONResultsForDataPoint];
    return dataPoint;
}

- (NSDictionary *)JSONResultsForDataPoint {
    
    // Construct dictionary of responses
    NSMutableDictionary *answers = [[NSMutableDictionary alloc] init];
    for (int i=0; i<self.questionsArray.count; i++) {
        [answers setObject:self.answersArray[i] forKey:self.questionsArray[i]];
    }
    
    NSDictionary *time = @{@"date_time" : [OMHDataPoint stringFromDate:[NSDate date]]};
    
    NSDictionary *results = @{@"effective_time_frame" : time,
                              @"test_type" : self.testType,
                              @"results" : answers};
    
    return results;
}

@end
