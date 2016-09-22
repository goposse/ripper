//
//  Operation.swift
//  Ripper
//
//  Created by Posse in NYC
//  http://goposse.com
//
//  Copyright (c) 2016 Posse Productions LLC.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  * Neither the name of the Posse Productions LLC, Posse nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL POSSE PRODUCTIONS LLC (POSSE) BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import UIKit
import Haitch
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



open class Operation {
  
  // MARK: - Properties
  internal var url: String?
  internal var imageName: String?
  internal var placeholderImage: UIImage?
  internal var target: UIImageView?
  internal var headers: [String : String]?
  
  internal var fetcher: ImageFetcher?
  internal var filters: [Filter]?
  internal var operationQueue: OperationQueue!
  internal var downloader: Ripper!
  
  
  // MARK: - Types
  enum State {
    case ready, executing, finished, cancelled
  }
  
  
  // MARK: - Initialization
  internal init(operationQueue: OperationQueue, downloader: Ripper) {
    self.operationQueue = operationQueue
    self.downloader = downloader
    self.fetcher = ImageFetcher(httpClient: downloader.httpClient)
    self.state = .ready
    self.headers = [:]
    self.filters = []
  }

  internal convenience init(operationQueue: OperationQueue, downloader: Ripper, target: UIImageView) {
    self.init(operationQueue: operationQueue, downloader: downloader)
    self.target = target
  }
  
  
  // MARK: - Properties
  var state: State = State.ready
  
  
  // MARK: - Operation modification
  open func placeholder(_ placeholderImage: UIImage) -> Operation {
    self.placeholderImage = placeholderImage
    return self
  }
  
  open func HTTPHeaders(_ headers: [String : String]) -> Operation {
    self.headers = headers
    return self
  }
  
  open func addHeader(_ key: String, value: String) -> Operation {
    if self.headers != nil {
      self.headers![key] = value
    }
    return self
  }

  open func addFilter(_ filter: Filter) -> Operation {
    if self.filters != nil {
      self.filters!.append(filter)
    }
    return self
  }

  
  // MARK: - Operation execution
  open func into(_ imageView: UIImageView) {
    self.into(imageView, callback: nil)
  }
  
  open func into(_ imageView: UIImageView, callback: ImageCallback?) {
    
    self.operationQueue.cancelOperation(target: imageView)    // cancel previous operations
    
    self.target = imageView
    if self.placeholderImage != nil {
      DispatchQueue.main.async(execute: { () -> Void in
        self.target?.image = self.placeholderImage
      })
    }
    self.execute { (image, error) in
      if image != nil && error == nil {
        imageView.image = image
      }
      // execute callback
      if callback != nil {
        callback!(image, error)
      }
    }
  }
  
  open func execute(_ callback: @escaping ImageCallback) {
    if self.state == .cancelled {
      // don't execute callback because it was cancelled
      self.operationQueue.finish(operation: self)
      return
    }
    
    self.state = .executing
    self.operationQueue.registerOperation(operation: self)    // registers operation execution in the queue
    
    if let fetchURL: String = self.url {
      // check the cache and return if image was found
      if let cachedImage: UIImage = self.downloader.imageCache.object(forKey: fetchURL as AnyObject) as? UIImage {
        var finalImage: UIImage? = cachedImage
        if self.downloader.imageCacheMode == .originals && self.filters?.count > 0 {
          finalImage = self.processImage(cachedImage)
        }
        callback(finalImage, nil)
        self.operationQueue.finish(operation: self)
        return
      }

      if let fetcher: ImageFetcher = self.fetcher {
        if self.headers != nil {
          fetcher.headers = self.headers!
        }
        fetcher.fetch(imageUrl: fetchURL, callback: { (image, error) in
          
          let finalImage: UIImage? = self.processImage(image)
          if image != nil && finalImage != nil {
            var cacheImage: UIImage = image!
            if self.downloader.imageCacheMode == .processed {
              cacheImage = finalImage!
            }
            self.downloader.imageCache.setObject(cacheImage, forKey: fetchURL as AnyObject)
          }

          // Cancelled - we're done
          if self.state == .cancelled {
            self.operationQueue.finish(operation: self)
            return
          }
          
          DispatchQueue.main.async(execute: { () -> Void in
            callback(finalImage, error)
            self.operationQueue.finish(operation: self)
          })
        })
      }
    } else if let imageName: String = self.imageName {
      let image: UIImage? = UIImage(named: imageName)
      let finalImage: UIImage? = self.processImage(image)
      callback(finalImage, nil)
      self.operationQueue.finish(operation: self)
    } else {
      callback(nil, nil)
      self.operationQueue.finish(operation: self)      
    }
  }
  
  
  // MARK: - Image processing
  internal func processImage(_ image: UIImage?) -> UIImage? {
    var finalImage: UIImage? = image
    if let srcImage: UIImage = image {
      finalImage = srcImage
      if self.filters != nil {
        for filter in self.filters! {
          let processedImage: UIImage? = filter.processImage(image: finalImage!)
          if processedImage != nil {
            finalImage = processedImage
          }
        }
      }
    }
    return finalImage
  }
  
  
  // MARK: - Operation management
  
  // NOTE: you should call cancel and finish from the queue unless you know absolutely what you're doing
  internal func cancel() {
    self.state = .cancelled
  }
  
  internal func finish() {
    self.state = .finished
  }
  
}
