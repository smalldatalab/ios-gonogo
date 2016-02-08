//
//  VASTableViewController.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 27/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "VASTableViewController.h"
#import "VASTableViewCell.h"

@interface VASTableViewController ()

@end

@implementation VASTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Done button
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)dismissView {
    // Save stuff first
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VASTableViewCell *cell = (VASTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"sliderCell" forIndexPath:indexPath];
    [cell.titleLabel setText:[NSString stringWithFormat:@"Question #%ld", (long)indexPath.row]];
    return cell;
}

@end
