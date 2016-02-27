//
//  ImpulsivityQuestions.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 12/02/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "ImpulsivityQuestions.h"

@implementation ImpulsivityQuestions

+ (NSString*)baselineVASInstructions {
    return @"Please answer the questions below using the slider that goes from 0 (Not at All like you) to 10 (Extremely like you). Each slider is set to moderately to begin.";
}

+ (NSString*)dailyVASInstructions {
    return @"Please answer the questions below using the slider that goes from 0 (Not at All) to 10 (Extremely) based on how you have been feeling today. Each slider is set to moderately to begin.";
}

+ (NSArray*)baselineVASQuestions {
    return @[@"I get distracted easily.",
             @"I do things that I end up regretting later.",
             @"I have difficulty controlling how much I check my mobile phone.",
             @"I stick to my long-term goals even if I am tempted by short-term pleasure.",
             @"I tend to do things that feel good in the short-term but are bad for me in the long-term.",
             @"I have difficulty controlling myself when I am tempted by something even if I don’t want to do it.",
             @"I have difficulty controlling how much I use social media.",
             @"I feel like I am missing out on fun activities going on around me.",
             @"I have difficulty completing tasks that require me to stay focused for long periods.",
             @"I tend to do things I regret because I get influenced by other people."];
}

+ (NSArray*)dailyVASQuestions {
    return @[@"I felt distracted.",
             @"I did or said things without thinking.",
             @"I felt well rested and alert.",
             @"I felt bored with what I was doing."];
}

@end
