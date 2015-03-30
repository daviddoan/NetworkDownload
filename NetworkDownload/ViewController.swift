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
var throughput = [Int]()
var throughputcalc = [Int]()
var dlTimerCount = 0
var latTimerCount = 0
var dlTimerRunning = false
var latTimerRunning = false

var filesize = 0

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    
    @IBOutlet weak var latText: UILabel!
    @IBOutlet weak var dlText: UILabel!
    @IBAction func showData(sender: AnyObject) {
        exportToCSV(self)
    }
    
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
    
    func dlCounting(){
        dlTimerCount += 1
        var speed = filesize / (dlTimerCount)
        dlText.text = "\(speed*100) bytes/s"
        println(dlTimerCount)
    }
    
    func latCounting() {
        latTimerCount += 1
        latText.text = "\(latTimerCount) ms"
        
    }
    
    @IBAction func Start(sender: AnyObject) {
        if dlTimerRunning == false {
            dlTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("dlCounting"), userInfo: nil, repeats: true)
            dlTimerRunning = true
            if dlTimerRunning == true {
                dlTimerCount = 0
                dlTimerRunning = false
            }
        }
        
        if latTimerRunning == false {
            latTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("latCounting"), userInfo: nil, repeats: true)
            latTimerRunning = true
            if latTimerRunning == true {
                latTimerCount = 0
                latTimerRunning = false
            }
        }
        
        
        throughput.removeAll()
        throughputcalc.removeAll()
        
        var data = getData()
        download(data)
    }

    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController! {
        return self
    }
    
    func exportToCSV(delegate: UIDocumentInteractionControllerDelegate) {
        let fileName = NSTemporaryDirectory().stringByAppendingPathComponent("Throughput.csv")
        let url: NSURL! = NSURL(fileURLWithPath: fileName)
        
        var data = ",\n".join(throughputcalc.map {"\($0.0)"})
        
        data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if url != nil {
            let documentController = UIDocumentInteractionController(URL: url)
            documentController.UTI = "public.comma-separated-values-text"
            documentController.delegate = delegate
            documentController.presentPreviewAnimated(true)
        }
    }

    
}

