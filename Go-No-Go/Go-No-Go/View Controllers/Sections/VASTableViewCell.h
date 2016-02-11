//
//  VASTableViewCell.h
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 08/02/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMMarkSlider.h"

@protocol VASTableViewCellProtocol <NSObject>

- (void)questionAtIndexPath:(NSIndexPath*)indexPath answeredWith:(NSNumber*)answer;

@end

@interface VASTableViewCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) id<VASTableViewCellProtocol> delegate;

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *valueLabel;
@property (nonatomic, assign) IBOutlet JMMarkSlider *slider;

@end
