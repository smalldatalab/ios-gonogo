//
//  UIColor+Additions.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 14/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "UIColor+Additions.h"
#define RANGE 255.0

@implementation UIColor (Additions)

+ (UIColor*)VALID_COLOR {
    return [UIColor colorWithRed:46/RANGE green:204/RANGE blue:113/RANGE alpha:1.0];
}

+ (UIColor*)INVALID_COLOR {
    return [UIColor colorWithRed:41/RANGE green:128/RANGE blue:185/RANGE alpha:1.0];
}

+ (UIColor *)belizeBlueColor {
    return [UIColor colorWithRed:41/RANGE green:128/RANGE blue:185/RANGE alpha:1.0];
}

@end
