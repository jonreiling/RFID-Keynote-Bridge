//
//  AppDelegate.swift
//  RFIDKeynoteBridge
//
//  Created by Jon Reiling on 1/6/16.
//  Copyright © 2016 Reiling. All rights reserved.
//

import Cocoa

enum SoundFXType: String {
    case portalActivated = "portalActivated.mp3"
    case buttonTap = "buttonTap.mp3"
    case doubleTap = "doubleTapTap.mp3"
    case tagPlaced = "tagPlaced.mp3"
    case tagRemoved = "tagRemoved.mp3"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CommunicationManagerDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    var keynoteManager : KeynoteManager!
    
    
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
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func onTagEnter(tag: String!) {
        
        self.playSoundFXType(.tagPlaced, fadeIn: true)
        
        print("tag = \(tag)")
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
        self.playSoundFXType(.tagRemoved, fadeIn: true)
        keynoteManager.gotoSectionWithName("IDLE")
        CommunicationManager.sharedInstance().sendCommand("disableButton")
    }
    
    func onButtonClick() {
        self.playSoundFXType(.buttonTap, fadeIn: true)
        keynoteManager.gotoNext()
    }
    
    func onButtonDoubleClick() {
        self.playSoundFXType(.doubleTap, fadeIn: true)
        keynoteManager.gotoPrevious()
    }
    
    func onPresenceDetected() {
        self.playSoundFXType(.portalActivated, fadeIn: true)
    }
    
    func onPresenceTimeout() {
        
    }

    func playSoundFXType(soundFXType: SoundFXType, fadeIn: Bool) {
        SoundManager.sharedManager().playSound(soundFXType.rawValue, looping: false, fadeIn: fadeIn)
    }
}

