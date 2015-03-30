//
//  NetworkDownload.swift
//  NetworkDownload
//
//  Created by David Doan on 3/28/15.
//  Copyright (c) 2015 David Doan. All rights reserved.
//

import Foundation
import UIKit
import Darwin

typealias CompleteHandlerBlock = () -> ()

class NetworkDownload : NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate {
    
    var handlerQueue: [String : CompleteHandlerBlock]!
    
    var lastCalled: NSDate = NSDate()
    
    class var sharedInstance: NetworkDownload {
        struct Static {
            static var instance : NetworkDownload?
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NetworkDownload()
            Static.instance!.handlerQueue = [String : CompleteHandlerBlock]()
        }
        
        return Static.instance!
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        println("session error: \(error?.localizedDescription).")
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        println("session \(session) has finished the download task \(downloadTask) of URL \(location).")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        
        if latTimer.valid && bytesWritten > 0 {
            latTimer.invalidate()
        }
        
        let now = NSDate()
        
        println(now.timeIntervalSinceDate(lastCalled))
    
        if now.timeIntervalSinceDate(lastCalled) < 1 {
            return
        }
        
        lastCalled = now
       
        throughput.append(totalBytesWritten)
    
        println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
       
        filesize = totalBytesExpectedToWrite

        }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int, expectedTotalBytes: Int) {
        println("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil {
            dlTimer.invalidate()
            println("session \(session) download completed")

            throughputcalc.append(throughput[0])
            for var i = 1; i < throughput.count; i++ {
                throughputcalc.append(throughput[i] - throughput[i-1])
            }
            println(throughput)
            println(throughputcalc)
            println(dlTimerCount)
            
            
        } else {
            println("session \(session) download failed with error \(error?.localizedDescription)")
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        println("background session \(session) finished events.")
        
        if !session.configuration.identifier.isEmpty {
            callCompletionHandlerForSession(session.configuration.identifier)
        }
    }
    
        
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        var handler : CompleteHandlerBlock = handlerQueue[identifier]!
        handlerQueue!.removeValueForKey(identifier)
        handler()
    }
}