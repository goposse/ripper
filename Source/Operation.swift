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


public class Operation {
  
  // MARK: - Properties
  internal var url: String?
  internal var imageName: String?
  internal var placeholderImage: UIImage?
  internal var target: UIImageView?
  internal var headers: [String : String]?
  
  internal var fetcher: ImageFetcher?
  internal var filters: [Filter]?
  internal var downloader: Ripper!

  
  // MARK: - Types
  enum State {
    case Ready, Executing, Finished, Cancelled
  }
  
  
  // MARK: - Initialization
  public init(downloader: Ripper, httpClient: HttpClient) {
    self.downloader = downloader
    self.fetcher = ImageFetcher(httpClient: httpClient)
    self.state = .Ready
    self.headers = [:]
    self.filters = []
  }

  public convenience init(downloader: Ripper, httpClient: HttpClient, target: UIImageView) {
    self.init(downloader: downloader, httpClient: httpClient)
    self.target = target
  }
  
  
  // MARK: - Properties
  var state: State = State.Ready
  
  
  // MARK: - Operation modification
  public func placeholder(placeholderImage: UIImage) -> Operation {
    self.placeholderImage = placeholderImage
    return self
  }
  
  public func HTTPHeaders(headers: [String : String]) -> Operation {
    self.headers = headers
    return self
  }
  
  public func addHeader(key: String, value: String) -> Operation {
    if self.headers != nil {
      self.headers![key] = value
    }
    return self
  }

  public func addFilter(filter: Filter) -> Operation {
    if self.filters != nil {
      self.filters!.append(filter)
    }
    return self
  }

  
  // MARK: - Operation execution
  public func into(imageView: UIImageView) {
    self.into(imageView, callback: nil)
  }
  
  public func into(imageView: UIImageView, callback: ImageCallback?) {
    self.target = imageView
    if self.placeholderImage != nil {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.target?.image = self.placeholderImage
      })
    }
    self.execute { (image, error) in
      if image != nil && error == nil {
        imageView.image = image
      }
      self.downloader.finishOperation(imageView)
      // execute callback
      if callback != nil {
        callback!(image: image, error: error)
      }
    }
  }
  
  public func execute(callback: ImageCallback) {
    if self.state == .Cancelled {
      // don't execute callback because it was cancelled
      return
    }
    
    self.state = .Executing
    
    if let fetchURL: String = self.url {
      // check the cache and return if image was found
      if let cachedImage: UIImage = self.downloader.imageCache.objectForKey(fetchURL) as? UIImage {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          let finalImage: UIImage? = self.processImage(cachedImage)
          self.finish()
          callback(image: finalImage, error: nil)
        })
        return
      }

      if let fetcher: ImageFetcher = self.fetcher {
        if self.headers != nil {
          fetcher.headers = self.headers!
        }
        fetcher.fetch(imageUrl: fetchURL, callback: { (image, error) in
          // Cancelled - we're done
          if self.state == .Cancelled {
            return
          }
          if image != nil {
            self.downloader.imageCache.setObject(image!, forKey: fetchURL)
          }
          let finalImage: UIImage? = self.processImage(image)
          self.finish()
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            callback(image: finalImage, error: error)
          })
        })
      }
    } else if let imageName: String = self.imageName {
      let image: UIImage? = UIImage(named: imageName)
      let finalImage: UIImage? = self.processImage(image)
      self.finish()
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        callback(image: finalImage, error: nil)
      })
    } else {
      self.finish()
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        callback(image: nil, error: nil)
      })
    }
  }
  
  
  // MARK: - Image processing
  internal func processImage(image: UIImage?) -> UIImage? {
    var finalImage: UIImage?
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
  public func cancel() {
    self.state = .Cancelled
  }
  
  public func finish() {
    self.state = .Finished
  }
  
}
