//
//  AppDelegate.swift
//  RFIDKeynoteBridge
//
//  Created by Jon Reiling on 1/6/16.
//  Copyright © 2016 Reiling. All rights reserved.
//

import Cocoa

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
        
        
        
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func onTagEnter(tag: String!) {
        
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
        keynoteManager.gotoSectionWithName("IDLE")
        CommunicationManager.sharedInstance().sendCommand("disableButton")
    }
    
    func onButtonClick() {
        keynoteManager.gotoNext()
    }
    
    func onButtonDoubleClick() {
        keynoteManager.gotoPrevious()
    }
    
    func onPresenceDetected() {
        
    }
    
    func onPresenceTimeout() {
        
    }


}

