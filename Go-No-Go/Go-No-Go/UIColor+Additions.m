//
//  UIColor+Additions.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 14/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor*)VALID_COLOR
{
    return [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1.0];
}

+ (UIColor*)INVALID_COLOR
{
    return [UIColor colorWithRed:41/255.0 green:128/255.0 blue:185/255.0 alpha:1.0];
}

@end
