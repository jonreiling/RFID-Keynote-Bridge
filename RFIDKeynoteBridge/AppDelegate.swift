//
//  AppDelegate.swift
//  RFIDKeynoteBridge
//
//  Created by Jon Reiling on 1/6/16.
//  Copyright © 2016 Reiling. All rights reserved.
//

import Cocoa

enum SoundFXType: String {
    case portalActivated = "portalActivated.m4a"
    case buttonTap = "buttonTap.mp3"
    case doubleTap = "doubleTapTap.mp3"
    case tagPlaced = "tagPlaced.m4a"
    case tagRemoved = "tagRemoved.m4a"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CommunicationManagerDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    var keynoteManager : KeynoteManager!
    @IBOutlet weak var statusLabel : NSTextField!
    
    
    @IBAction func begin(sender:AnyObject) {
        keynoteManager.startSlideshow()
        keynoteManager.gotoSectionWithName("IDLE")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        CommunicationManager.sharedInstance().delegate = self
        CommunicationManager.sharedInstance().connect()
        keynoteManager = KeynoteManager()
        
        //        var timer = NSTimer.scheduledTimerWithTimeInterval(6.0, target: self, selector: "exitTest", userInfo: nil, repeats: true)
        //      NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        
        // Initializes the SoundManager
        SoundManager.sharedManager().prepareToPlay()
        SoundManager.sharedManager().soundVolume = 0.2
        self.preloadSoundFXType(.tagPlaced)
        self.preloadSoundFXType(.tagRemoved)
        self.preloadSoundFXType(.portalActivated)
        
        
  //      down vote
//        This one worked for me, hope that can be helpful
        
//        [self.window makeKeyAndOrderFront:nil];
  //      [self.window setLevel:NSStatusWindowLevel];
        self.window.makeKeyAndOrderFront(nil)
        self.window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.StatusWindowLevelKey))
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func onTagEnter(tag: String!) {
        
        self.playSoundFXType(.portalActivated)
        
        print("tag = \(tag)")
        statusLabel.stringValue = "tag = \(tag)"
        keynoteManager.gotoSectionWithName(tag)
        
        let slidesInSection = keynoteManager.slidesInSection(tag)
        
        if slidesInSection == 0 {
            
        } else if keynoteManager.slidesInSection(tag) == 1 {
           CommunicationManager.sharedInstance().sendCommand("disableButton")
        } else {
            CommunicationManager.sharedInstance().sendCommand("enableButton")
        }
    }
    
    func onTagLeave() {
        statusLabel.stringValue = "tag leave"
        self.playSoundFXType(.tagRemoved)
        keynoteManager.gotoSectionWithName("IDLE")
        CommunicationManager.sharedInstance().sendCommand("disableButton")
    }
    
    func onButtonClick() {
        statusLabel.stringValue = "onButtonClick"
        print("onButtonClick")
        self.playSoundFXType(.buttonTap)
        keynoteManager.gotoNext()
    }
    
    func onButtonDoubleClick() {
        self.playSoundFXType(.doubleTap)
        keynoteManager.gotoPrevious()
    }
    
    func onPresenceDetected() {
        statusLabel.stringValue = "onPresenceDetected"
        
        print("onPresenceDetected");
        self.playSoundFXType(.portalActivated)
    }
    
    func onPresenceTimeout() {
        statusLabel.stringValue = "onPresenceTimeout"
        print("onPresenceTimeout");
        
    }

    func playSoundFXType(soundFXType: SoundFXType) {
        SoundManager.sharedManager().playSound(soundFXType.rawValue, looping: false, fadeIn: false)
    }
    
    func preloadSoundFXType(soundFXType: SoundFXType) {
        SoundManager.sharedManager().prepareToPlayWithSound(soundFXType.rawValue)
    }
}

