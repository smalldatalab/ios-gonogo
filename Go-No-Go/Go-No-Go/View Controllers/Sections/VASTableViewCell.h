//
//  VASTableViewCell.h
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 08/02/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VASTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *valueLabel;
@property (nonatomic, assign) IBOutlet UISlider *slider;

@end
