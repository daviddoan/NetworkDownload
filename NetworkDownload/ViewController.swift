//
//  ViewController.swift
//  NetworkDownload
//
//  Created by David Doan on 3/28/15.
//  Copyright (c) 2015 David Doan. All rights reserved.
//

import UIKit

var dlTimer = NSTimer()
var latTimer = NSTimer()

class ViewController: UIViewController {
    var dlTimerCount = 0
    var latTimerCount = 0
    var dlTimerRunning = false
    var latTimerRunning = false
    
    @IBOutlet weak var latText: UILabel!
    @IBOutlet weak var dlText: UILabel!
    
    
    var delegate = NetworkDownload.sharedInstance
    
    //MARK: NSURLSession download in background
    func download(data: [String]!) {
        var configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.identifier)
        var backgroundSession = NSURLSession(configuration: configuration, delegate: self.delegate, delegateQueue: nil)
        //        for stringUrl in data {
        var url = NSURLRequest(URL: NSURL(string: data[0])!)
        var downloadTask = backgroundSession.downloadTaskWithRequest(url)
        downloadTask.resume()
        //        }
    }
    
    func dlCounting() {
        dlTimerCount += 1
        var speed = 650924 / (dlTimerCount)
        dlText.text = "\(speed*1000) bytes/s"
    }
    
    func latCounting() {
        latTimerCount += 1
        latText.text = "\(latTimerCount) ms"
        
    }
    
    @IBAction func Start(sender: AnyObject) {
        if dlTimerRunning == false {
            dlTimer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("dlCounting"), userInfo: nil, repeats: true)
            dlTimerRunning = true
            if dlTimerRunning == true {
                dlTimerCount = 0
                dlTimerRunning = false
            }
        }
        
        if latTimerRunning == false {
            latTimer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("latCounting"), userInfo: nil, repeats: true)
            latTimerRunning = true
            if latTimerRunning == true {
                latTimerCount = 0
                latTimerRunning = false
            }
        }
        
        var data = getData()
        download(data)
    }
    
}

