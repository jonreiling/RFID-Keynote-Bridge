//
//  PreferencesManager.m
//  AKQAWorkDisplay
//
//  Created by Jon Reiling on 1/1/15.
//  Copyright (c) 2015 AKQA. All rights reserved.
//

#import "PreferencesManager.h"
#import "Constants.h"

@implementation PreferencesManager

-(NSString*)getPreference:(NSString*)preferenceName withDefault:(NSString*)defaultValue {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *object = [defaults objectForKey:preferenceName];
    
    return ( object != nil ) ? object : defaultValue;
    
}

-(void)setPreference:(NSString*)preferenceName withValue:(NSString*)preferenceValue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:preferenceValue forKey:preferenceName];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Singleton methods

+(PreferencesManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static id sharedInstance;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}


@end
