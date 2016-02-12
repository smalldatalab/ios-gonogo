//
//  ImpulsivityQuestions.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 12/02/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "ImpulsivityQuestions.h"

@implementation ImpulsivityQuestions

+ (NSArray*)baselineVASQuestions {
    return [[NSArray alloc] initWithObjects:
            @"I get distracted easily.",
            @"I do things that I end up regretting later.",
            @"I have difficulty controlling how much I check my mobile phone.",
            @"I stick to my long-term goals even if I am tempted by short-term pleasure.",
            @"I tend to do things that feel good in the short-term but are bad for me in the long-term.",
            @"I have difficulty controlling my impulses when I am tempted by something even if I don’t want to do it.",
            @"I have difficulty controlling how much I use social media.",
            @"I feel like I am missing out on fun activities going on around me.",
            @"I have difficulty completing tasks that require me to stay focused for long periods.",
            @"I tend to do things I regret because I get influenced by other people.",
            nil];
}

+ (NSArray*)morningVASQuestions {
    return [[NSArray alloc] initWithObjects:
            @"Overall, I have felt focused (not distracted) over the last couple of hours.",
            @"Overall, I got a good nights sleep last night.",
            nil];
}

+ (NSArray*)eveningVASQuestions {
    return [[NSArray alloc] initWithObjects:
            @"Overall, I have felt focused (not distracted) over the last couple of hours.",
            @"Overall, I got a good nights sleep last night.",
            nil];
}


@end
