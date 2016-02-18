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
    self.slider.selectedBarColor = [UIColor colorWithRed:0.0021 green:0.5427 blue:0.8975 alpha:1.0];
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
    [self.digitValueLabel setText:[NSString stringWithFormat:@"%ld", (long)self.slider.value]];
}

@end
