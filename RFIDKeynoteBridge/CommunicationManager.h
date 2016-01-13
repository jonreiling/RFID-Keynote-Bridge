//
//  CommunicationManager.h
//  AKQAWorkDisplay
//
//  Created by Jon Reiling on 12/31/14.
//  Copyright (c) 2014 AKQA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Matatino/Matatino.h>


@protocol CommunicationManagerDelegate
@required

#pragma CommunicationManager Delegate

-(void)onTagEnter:(NSString*)tag;
-(void)onTagLeave;
-(void)onPresenceDetected;
-(void)onPresenceTimeout;
-(void)onButtonClick;
-(void)onButtonDoubleClick;
@end

@interface CommunicationManager : NSObject <MatatinoDelegate>
{
    Matatino *arduino;
    id <CommunicationManagerDelegate> delegate;
}
@property (retain) id delegate;
+(CommunicationManager *)sharedInstance;
-(void)connect;
-(void)disconnect;
-(NSArray*)getAvailablePorts;
-(BOOL)isConnected;
-(void)sendCommand:(NSString*)command;

@end

