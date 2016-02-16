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

    // Customize slider
    self.slider.selectedBarColor = [UIColor colorWithRed:0.0014 green:0.8571 blue:0.0 alpha:1.0];
    self.slider.unselectedBarColor = [UIColor lightGrayColor];
    
    self.slider.markColor = [UIColor whiteColor];
    self.slider.markPositions = @[@10, @20, @30, @40, @50, @60, @70, @80, @90];
    self.slider.markWidth = 1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)sliderChanged:(id)sender {
    // Round value to closest int
    long sliderValue = lroundf(self.slider.value);
    [self.slider setValue:sliderValue animated:YES];
    
    // Set value label
    [self updateValueLabel];
    
    // Notify delegate
    if (self.delegate) {
        [self.delegate questionAtIndexPath:self.indexPath answeredWith:@(sliderValue)];
    }
}

- (void)updateValueLabel {
    
    switch ((int)self.slider.value) {
        case 0:
            [self.valueLabel setText:[NSString stringWithFormat:@"Never"]];
            break;
            
        case 5:
            if (self.isBaselineQuestion) {
                [self.valueLabel setText:[NSString stringWithFormat:@"Half the time"]];
            } else {
                [self.valueLabel setText:[NSString stringWithFormat:@"Moderately"]];
            }
            break;
            
        case 10:
            if (self.isBaselineQuestion) {
                [self.valueLabel setText:[NSString stringWithFormat:@"All the time"]];
            } else {
                [self.valueLabel setText:[NSString stringWithFormat:@"Extremely"]];
            }
            break;
            
        default:
            [self.valueLabel setText:[NSString stringWithFormat:@"%ld", (long)self.slider.value]];
            break;
    }
}

@end
