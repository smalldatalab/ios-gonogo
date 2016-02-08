//
//  VASTableViewCell.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 08/02/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "VASTableViewCell.h"

@implementation VASTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)sliderChanged:(id)sender {
    
    // Round value to closest int
    UISlider *slider = (UISlider*)sender;
    int sliderValue = (int)lroundf(slider.value);
    [slider setValue:sliderValue animated:YES];
    
    // Set value label
    if (sliderValue == 0) {
        [self.valueLabel setText:[NSString stringWithFormat:@"None at All"]];
    } else {
        [self.valueLabel setText:[NSString stringWithFormat:@"%d", sliderValue]];
    }
}

@end
