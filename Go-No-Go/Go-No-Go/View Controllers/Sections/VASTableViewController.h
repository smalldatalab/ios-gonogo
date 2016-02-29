//
//  VASTableViewController.h
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 27/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VASTableViewController : UITableViewController

typedef NS_ENUM(NSUInteger, TestTypeEnum) {
    baselineTestType = 1,
    dailyTestType = 2
};

@property (nonatomic, assign) TestTypeEnum testType;

@end
