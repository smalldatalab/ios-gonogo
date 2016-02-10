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
    // Add value steps if possible
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
    if (self.slider.value == 0) {
        [self.valueLabel setText:[NSString stringWithFormat:@"Never"]];
    } else if (self.slider.value == 10) {
        [self.valueLabel setText:[NSString stringWithFormat:@"All the time"]];
    } else {
        [self.valueLabel setText:[NSString stringWithFormat:@"%ld", (long)self.slider.value]];
    }
}

@end
