//
//  GOConstants.m
//  Go-No-Go
//
//  Created by Anas Bouzoubaa on 12/01/16.
//  Copyright © 2016 Small Data Lab. All rights reserved.
//

#import "AppConstants.h"

#define MSEC_PER_SEC 1000.0;

NSString * const kDSUClientID = @"io.smalldata.ios.goNoGo";
NSString * const kHAS_COMPLETED_BASELINE = @"HAS_COMPLETED_BASELINE";

@implementation AppConstants

// Durations for go/no-go test animations
NSTimeInterval const DURATION_FIXATION_CROSS   = 300 / MSEC_PER_SEC;
NSTimeInterval const DURATION_BLANK_SCREEN     = 400 / MSEC_PER_SEC;
NSTimeInterval const DURATION_TARGET_ON_SCREEN = 600 / MSEC_PER_SEC;
NSTimeInterval const DURATION_WAIT_LAP         = 100 / MSEC_PER_SEC;

+ (NSString *)googleClientID
{
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    if ([bundleID isEqualToString:@"io.smalldatalab.goNoGo"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist"];
        if (path) {
            return [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"GoogleClientID"];
        }
    }
    return nil;
}

+ (NSString *)DSUClientSecret
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist"];
    if (path) {
        return [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"DSUClientSecret"];
    }
    return nil;
}

+ (OMHSchemaID *)schemaID
{
    static OMHSchemaID *sSchemaID = nil;
    if (!sSchemaID) {
        sSchemaID = [[OMHSchemaID alloc] init];
        sSchemaID.schemaNamespace = @"cornell";
        sSchemaID.name = @"go_no_go_test_results";
        sSchemaID.version = @"1.0";
    }
    return sSchemaID;
}

+ (OMHSchemaID *)BARTschemaID
{
    static OMHSchemaID *sSchemaID = nil;
    if (!sSchemaID) {
        sSchemaID = [[OMHSchemaID alloc] init];
        sSchemaID.schemaNamespace = @"cornell";
        sSchemaID.name = @"balloon_analogue_risk_test_results";
        sSchemaID.version = @"1.0";
    }
    return sSchemaID;
}

+ (OMHSchemaID *)VASschemaID
{
    static OMHSchemaID *sSchemaID = nil;
    if (!sSchemaID) {
        sSchemaID = [[OMHSchemaID alloc] init];
        sSchemaID.schemaNamespace = @"cornell";
        sSchemaID.name = @"vas_results";
        sSchemaID.version = @"1.0";
    }
    return sSchemaID;
}

+ (OMHAcquisitionProvenance *)acquisitionProvenance
{
    static OMHAcquisitionProvenance *sProvenance = nil;
    if (!sProvenance) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        sProvenance = [[OMHAcquisitionProvenance alloc] init];
        sProvenance.sourceName = [NSString stringWithFormat:@"GoNoGo-iOS-%@", version];
        sProvenance.modality = OMHAcquisitionProvenanceModalitySelfReported;
    }
    return sProvenance;
}

@end
