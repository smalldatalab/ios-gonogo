//
//  VASTableViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 27/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "VASTableViewController.h"
#import "VASTableViewCell.h"

NSString* const kSliderCellReuseIdentifier = @"kSliderCellReuseIdentifier";

@interface VASTableViewController () <VASTableViewCellProtocol>

@property (strong, nonatomic) NSArray<NSString*> *questionsArray;
@property (strong, nonatomic) NSMutableArray<NSNumber*> *answersArray;

@end

@implementation VASTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Done button
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
    
    // Questions
    self.questionsArray = [[NSArray alloc] initWithObjects:
                           @"I do things that I end up regretting later",
                           @"I have difficulty controlling how much I check my mobile phone",
                           @"I stick to my long-term goals even if I am tempted by short-term pleasure. ",
                           @"I tend to do things that feel good in the short-term but are bad for me in the long-term",
                           @"I have difficulty controlling my impulses when I am tempted by something even if I don’t want to do it. ",
                           @"I have difficulty controlling how much I use social media",
                           @"I feel like I am missing out on fun activities going on around me",
                           @"I have difficulty completing tasks that require me to stay focused for long periods",
                           @"I tend to do things I regret because I get influenced by other people ",
                           nil];

    // Fill answers with 0s
    self.answersArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.questionsArray.count; i++) {
        [self.answersArray addObject:@0];
    }
}

- (void)dismissView {
    //TODO: Save responses
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)questionAtIndexPath:(NSIndexPath *)indexPath answeredWith:(NSNumber *)answer {
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
    if (cell.slider.value == 0) {
        [cell.valueLabel setText:[NSString stringWithFormat:@"Never"]];
    } else if (cell.slider.value == 10) {
        [cell.valueLabel setText:[NSString stringWithFormat:@"All the time"]];
    } else {
        [cell.valueLabel setText:[NSString stringWithFormat:@"%ld", (long)cell.slider.value]];
    }
    
    return cell;
}

@end
