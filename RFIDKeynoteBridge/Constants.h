//
//  Constants.h
//  AKQAWorkDisplay
//
//  Created by Eddie Espinal on 10/26/14.
//  Copyright (c) 2014 AKQA, Inc. All rights reserved.
//

#ifndef AKQAWorkDisplay_Constants_h
#define AKQAWorkDisplay_Constants_h

static NSString * const kSerialPortChanged = @"kSerialPortChanged";
static NSString * const kSerialPortClosed = @"kSerialPortClosed";

static NSString * const kPreferenceContentDownloadLocation = @"downloadLocation";
static NSString * const kPreferenceContentDownloadLocationDefault = @"http://jonreiling.com/work-display/Data.zip";

static NSString * const kPreferenceResetTag = @"resetTag";
static NSString * const kPreferenceResetTagDefault = @"FFFFFFFF";

static NSString * const kPreferenceSelectedPort = @"selectedPort";
static NSString * const kPreferenceSelectedPortDefault = @"/dev/cu.usbmodem1451";

static NSString * const kSlideSetIdle = @"idle";
static NSString * const kSlideSetInstructions = @"instructions";


#endif
