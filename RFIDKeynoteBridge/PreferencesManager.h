//
//  PreferencesManager.h
//  AKQAWorkDisplay
//
//  Created by Jon Reiling on 1/1/15.
//  Copyright (c) 2015 AKQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesManager : NSObject
+(PreferencesManager *)sharedInstance;
-(NSString*)getPreference:(NSString*)preferenceName withDefault:(NSString*)defaultValue;
-(void)setPreference:(NSString*)preferenceName withValue:(NSString*)preferenceValue;
@end
