//
//  KeynoteManager.swift
//  AppleSCriptTest
//
//  Created by Jon Reiling on 1/6/16.
//  Copyright © 2016 Reiling. All rights reserved.
//

import Foundation


public class KeynoteManager:NSObject {
    
    var slides:[Slide] = []
    
    override init() {

        super.init()
        
        populateSlides()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "monitorForIdleLoop", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

    }
    
    
    public func startSlideshow() {
        
        populateSlides()
        
        let command = "tell application \"Keynote\" \n set keynoteFile to front document \n start keynoteFile from slide 1 of keynoteFile \n end tell"
        runCommand(command)
    }
    
    public func gotoSectionWithName(name:String) {
        for slide in slides {
            if slide.name == name {
                gotoSectionAtIndex(slide.index)
            }
        }
    }

    public func gotoNext() {
        
        let index = currentSlideIndex()
        
        //Check to see if the next slide is the start of a new section.
        if slides[index + 1].name != "" {
            
            //If it is, loop back to the beginning of the current section
            let previousSectionSlide = getPreviousSection(index)
            loopToSection(previousSectionSlide)
            
        } else {
            
            //otherwise proceed to the next slide
            let command = "tell application \"Keynote\" \n show next \n end tell"
            runCommand(command)
        }
        
    }
    
    public func gotoPrevious() {
        
        let index = currentSlideIndex()
        
        if slides[index-1].name != "" {
            
            let endOfSectionSlide = getEndOfSection(index)
            gotoSlide(endOfSectionSlide)
            
        } else {
            let command = "tell application \"Keynote\" \n show previous \n end tell"
            runCommand(command)
        }
    }
    
    public func currentSlideIndex() -> Int {
        
        let command = "tell application \"Keynote\" \n set keynoteFile to front document \n set t to slide number of current slide of keynoteFile \n end tell \n return t";
        
        if let response = runCommand(command) {
            return Int(response)! - 1
        } else {
            return -1
        }
    }
    
    public func slidesInSection(title:String) -> Int {
        
        var startCount:Bool = false;
        var length:Int = 0;
        
        for index in 0...(slides.count-1) {
            
            if (slides[index].name != "" && startCount ) {
                break
            }
            
            if (startCount) {
                length++
            }
            
            
            if slides[index].name == title {
                startCount = true;
            }
        }
        
        return length
    }

    
    private func gotoSlide(index:Int) {
        
        let command = "tell application \"Keynote\" \n set keynoteFile to front document \n show slide \(index+1) of keynoteFile \n end tell"
        runCommand(command)
    }
    
    private func gotoSectionAtIndex(index:Int) {
        
        let command = "tell application \"Keynote\" \n set keynoteFile to front document \n show slide \(index+1) of keynoteFile \n show next \n end tell"
        runCommand(command)
    }
    
    private func loopToSection(index:Int) {
        
        let command = "tell application \"Keynote\" \n show next \n delay 0.5 \n set keynoteFile to front document \n show slide \(index+1) of keynoteFile \n show next \n end tell"
        runCommand(command)
    }
    
    
    private func getPreviousSection( index:Int ) -> Int {
        
        for i in index.stride(through: 1, by: -1) {
            
            if slides[i].name != "" {
                return i
            }
            
        }
        return 1
    }
    
    private func getEndOfSection( index:Int ) -> Int {
        for i in index.stride(through: slides.count, by: 1) {
            
            if slides[i].name != "" {
                return i - 1
            }
            
        }
        return 1
    }
    
    private func notesForSlide(slideNumber:Int) -> String {
        
        let command = "tell application \"Keynote\" \n set keynoteFile to front document \n set t to presenter notes of slide \(String(slideNumber)) of keynoteFile \n end tell \n return t";
        
        if let response = runCommand(command) {
            return response
        } else {
            print("end of the line")
            return "end"
        }
        
    }
    
    
    internal func monitorForIdleLoop() {
        
        let index = currentSlideIndex()
        if slides[index].name == "IDLE_LOOP" {
            gotoSectionWithName("IDLE")
        }
    }
    
    
    private func runCommand(command:String) -> String? {
        
        let startAtLoginScript: NSAppleScript = NSAppleScript(source: command)!
        var possibleError: NSDictionary?
        
        let results = startAtLoginScript.executeAndReturnError(&possibleError).stringValue
        
        return results
    }
    
    private func populateSlides() {
        
        slides = []
        var currentVal:String = ""
        
        while (currentVal != "end") {
            
            currentVal = notesForSlide(slides.count + 1)
            
            if ( currentVal != "end" ) {
                let slide = Slide(name: currentVal,index: slides.count)
                slides.append(slide)
            }
        }
        
    }
    
    //    var slides:[Slide] = []

    
}