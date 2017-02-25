//
//  ModelController.swift
//  VT
//
//  Created by Jason Southwell on 2/24/17.
//  Copyright © 2017 Jason Southwell. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class PhotoPinModelHandler {
    
    func deleteSelectedImage(photo: Photo) {
        
        if !(photo.isFavorite) {
            
            getContext().delete(photo)
            
            do {
                try getContext().save()
                
                
            } catch  {
                
                print("Cannot delete photo")
                
            }

            
        }
        
    }
    
    
    
    func addToFavorites(passedPhoto: Photo) {
        
        passedPhoto.isFavorite = true
        
        do {
            try getContext().save()
            
            print("favorited!")
            
        } catch  {
            
            print("Cannot favorite photo")
            
        }
        
        
    }
    
    func storePin(latitude: Double, longitude: Double, name: String) -> AnyObject? {
        
        //        var currentPin = Pin()
        
        let currentPin = Pin(context: getContext())
        
        let latitude = latitude
        
        let longitude = longitude
        
        let name = name
        
        currentPin.latitude = latitude
        
        currentPin.longitude = longitude
        
        currentPin.name = name
        
        do {
            
            try getContext().save()
            
            
        } catch let error as NSError  {
            
            
            print("Could not save \(error), \(error.userInfo)")
            
            return nil
        }
        
        return currentPin
    }
    
    func storePhotosByPin(passedPhotos: [[String: AnyObject]], passedPin: Pin) {
        
        for passedPhoto in passedPhotos {
            
            let photo = Photo(context: getContext())
            
            if let url = (passedPhoto["url_l"] as? String), let text = (passedPhoto["title"] as? String) {
                
                photo.url = url
                
                photo.text = text
                
                Alamofire.request(url).responseData(completionHandler: { response in
                    
                    if let data = response.result.value {
                        
                        let photoData = NSData(data: data)
                        
                        photo.photo = photoData
                        
                        photo.pin = passedPin
                        
                        do {
                            
                            try getContext().save()
                            
                            
                        } catch let error as NSError {
                            
                            print("Save error: \(error), description: \(error.userInfo)")
                            
                            
                        }
                        

                    }
                    
                    
                
                })
                
                
            
            }
            
        }
        
        
    }
    
    
}


public class AsynchronousOperation : Operation {
    
    override public var isAsynchronous: Bool { return true }
    
    private let stateLock = NSLock()
    
    private var _executing: Bool = false
    override private(set) public var isExecuting: Bool {
        get {
            return stateLock.withCriticalScope { _executing }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            stateLock.withCriticalScope { _executing = newValue }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _finished: Bool = false
    override private(set) public var isFinished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValue(forKey: "isFinished")
            stateLock.withCriticalScope { _finished = newValue }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting
    
    public func completeOperation() {
        if isExecuting {
            isExecuting = false
        }
        
        if !isFinished {
            isFinished = true
        }
    }
    
    override public func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        main()
    }
}

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 An extension to `NSLock` to simplify executing critical code.
 
 From Advanced NSOperations sample code in WWDC 2015 https://developer.apple.com/videos/play/wwdc2015/226/
 From https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip
 */

extension NSLock {
    
    /// Perform closure within lock.
    ///
    /// An extension to `NSLock` to simplify executing critical code.
    ///
    /// - parameter block: The closure to be performed.
    
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    
    fileprivate var operations = [Int: DownloadOperation]()
    
    /// Serial NSOperationQueue for downloads
    
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 1    // I'd usually use values like 3 or 4 for performance reasons, but OP asked about downloading one at a time
        
        return _queue
    }()
    
    /// Delegate-based NSURLSession for DownloadManager
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /// Add download
    ///
    /// - parameter URL:  The URL of the file to be downloaded
    ///
    /// - returns:        The DownloadOperation of the operation that was queued
    
    @discardableResult
    func addDownload(_ url: URL) -> DownloadOperation {
        let operation = DownloadOperation(session: session, url: url)
        operations[operation.task.taskIdentifier] = operation
        queue.addOperation(operation)
        return operation
    }
    
    /// Cancel all queued operations
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
    
}

// MARK: URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadManager: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        let key = task.taskIdentifier
        operations[key]?.urlSession(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
    
}

/// Asynchronous Operation subclass for downloading

class DownloadOperation : AsynchronousOperation {
    let task: URLSessionTask
    
    init(session: URLSession, url: URL) {
        task = session.downloadTask(with: url)
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
}

// MARK: NSURLSessionDownloadDelegate methods

extension DownloadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let manager = FileManager.default
            let destinationURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
            if manager.fileExists(atPath: destinationURL.path) {
                try manager.removeItem(at: destinationURL)
            }
            try manager.moveItem(at: location, to: destinationURL)
        } catch {
            print("\(error)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
}

// MARK: NSURLSessionTaskDelegate methods

extension DownloadOperation: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        completeOperation()
        if error != nil {
            print("\(String(describing: error))")
        }
    }
    
}


