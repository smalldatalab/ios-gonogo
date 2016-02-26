//
//  ImpulsivityQuestions.h
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 12/02/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImpulsivityQuestions : NSObject

+ (NSString*)baselineVASInstructions;
+ (NSString*)dailyVASInstructions;

+ (NSArray*)baselineVASQuestions;
+ (NSArray*)morningVASQuestions;
+ (NSArray*)eveningVASQuestions;

@end
