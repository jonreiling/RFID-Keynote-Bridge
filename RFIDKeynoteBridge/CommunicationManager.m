//
//  CommunicationManager.m
//  AKQAWorkDisplay
//
//  Created by Jon Reiling on 12/31/14.
//  Copyright (c) 2014 AKQA. All rights reserved.
//

#import "CommunicationManager.h"
#import "PreferencesManager.h"
#import "Constants.h"
#import <AppKit/AppKit.h>

@implementation CommunicationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)connect
{
    if (arduino)
    {
        [arduino disconnect];
        arduino.delegate = nil;
        arduino = nil;
    }
    
    arduino = [[Matatino alloc] initWithDelegate:self];
    NSLog(@"WHAT %@", [arduino deviceNames]);
    
    // Make sure it isn't already connected
    if (![arduino isConnected])
    {
        NSString *serialPort = [[PreferencesManager sharedInstance] getPreference:kPreferenceSelectedPort withDefault:kPreferenceSelectedPortDefault];

        for (int i = 0 ; i < [arduino.deviceNames count] ; i ++ ) {
            
            NSString *dN = [arduino.deviceNames objectAtIndex:i];
            if ( [dN rangeOfString:@"usb"].location != NSNotFound ) {
                serialPort = dN;
            }
            
            
        }
        
        
        
        
        if (!serialPort)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Serial Port not found!"];
            [alert setInformativeText:@"Please select a Serial Port from the Preferences window and try again."];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
//            [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
        }
        
        // Connect to your device with 9600 baud
        if([arduino connect:serialPort withBaud:B115200]) {
            NSLog(@"Connection success!");
        } else {
            NSLog(@"Connection fail");

            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:CommunicationManager.sharedInstance selector:@selector(connect) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

        
        }
        
    } else {
        NSLog(@"Arduino already connected");
    }
}

-(NSArray*)getAvailablePorts {
    return arduino.deviceNames;
}

-(BOOL)isConnected {
    return arduino.isConnected;
}

-(void)disconnect {
    [arduino disconnect];
}

-(void)sendCommand:(NSString*)command {
  
    NSString *commandJSON = [[NSString alloc] initWithFormat:@"{\"command\":\"%@\"}",command];
    NSLog(@"Send command %@" ,commandJSON);
    [arduino send:commandJSON];
}

#pragma mark -
#pragma mark Event processing

-(void)processEvent:(NSDictionary*)eventDictionary {
    
    NSString *event = [eventDictionary objectForKey:@"e"];

    //Clever solution for switching on string from
    //http://stackoverflow.com/questions/8161737/can-objective-c-switch-on-nsstring
    NSArray *possibleEvents = @[@"t",@"p",@"b"];
    NSInteger eventIndex = [possibleEvents indexOfObject:event];
    
    switch (eventIndex) {
        case 0:
            //Tag event. See which delegate method we need to fire.
            [self processTagEvent:eventDictionary];
            break;
        case 1:
            [self processPresenceEvent:eventDictionary];
            break;
        case 2:
            [self processButtonEvent:eventDictionary];
            break;
        default:
            break;
    }
}

-(void)processTagEvent:(NSDictionary*)eventDictionary{
    
    NSString *tagValue = [eventDictionary objectForKey:@"v"];
    
    if ( [tagValue isEqualToString:@"NONE"]){
        [self.delegate onTagLeave];
    } else {
        [self.delegate onTagEnter:tagValue];
    }
}

-(void)processPresenceEvent:(NSDictionary*)eventDictionary {
    
    NSString *presenceValue = [eventDictionary objectForKey:@"v"];

    if ( [presenceValue isEqualToString:@"t"]){
        [self.delegate onPresenceDetected];
    } else {
        [self.delegate onPresenceTimeout];
    }
}

-(void)processButtonEvent:(NSDictionary*)eventDictionary {

    NSString *buttonValue = [eventDictionary objectForKey:@"v"];
    
    if ( [buttonValue isEqualToString:@"double"]){
        [self.delegate onButtonDoubleClick];
    } else {
        [self.delegate onButtonClick];
    }
}



#pragma mark -
#pragma mark Matatino delegate methods

- (void) receivedString:(NSString *)rx {
    
    // rx comes with a few extra characters from the arduino. Let's remove them here.
    rx = [rx stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];

    NSData *data = [rx dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    NSDictionary *eventJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (!error) {
        [self processEvent:eventJSON];
    }
    
    
}

- (void) portAdded:(NSArray *)ports
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:arduino.deviceNames,@"ports", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSerialPortChanged object:nil userInfo:userInfo];
}

- (void) portRemoved:(NSArray *)ports
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:arduino.deviceNames,@"ports", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSerialPortChanged object:nil userInfo:userInfo];

}

- (void) portClosed
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:arduino.deviceNames,@"ports", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSerialPortClosed object:nil userInfo:userInfo];
    
    
    //NSTimer timer* = NSTimer.scheduledTimerWithTimeInterval(6.0, target: sharedInstance, selector: "connect", userInfo: nil, repeats: false)
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:CommunicationManager.sharedInstance selector:@selector(connect) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    
}

#pragma mark -
#pragma mark Singleton methods

+(CommunicationManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static id sharedInstance;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}

@end
