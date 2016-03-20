//
//  GOConstants.h
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 12/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMHDataPoint.h"

/**
 *  DSU Sign-in keys
 */
extern NSString * const kDSUClientID;

/**
 *  Others
 */
extern NSString * const kHAS_COMPLETED_BASELINE;
extern NSString * const kHasRequestedPermissionKey;
extern NSString * const kMorningReminderTime;
extern NSString * const kEveningReminderTime;
extern NSString * const kDidGoThroughResearcherCode;
extern NSString * const kResearcherCode;

@interface AppConstants : NSObject

/**
 *  GO/NO-GO Test Durations
 */
extern NSTimeInterval const DURATION_FIXATION_CROSS;
extern NSTimeInterval const DURATION_BLANK_SCREEN;
extern NSTimeInterval const DURATION_TARGET_ON_SCREEN;
extern NSTimeInterval const DURATION_WAIT_LAP;

+ (NSString *)googleClientID;
+ (NSString *)DSUClientSecret;
+ (OMHSchemaID *)schemaID;
+ (OMHSchemaID *)BARTschemaID;
+ (OMHSchemaID *)VASschemaID;
+ (OMHAcquisitionProvenance *)acquisitionProvenance;

@end
