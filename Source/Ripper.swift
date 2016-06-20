//
//  Ripper.swift
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

import UIKit
import Haitch

public enum ImageCacheMode {
  case Originals
  case Processed
}

public class Ripper {
  
  // MARK: - Internal / private properties
  internal var placeholderImage: UIImage?
  internal var resizeFilter: ScaleFilter?
  internal var httpClient: HttpClient!
  internal var imageCache: NSCache!
  internal var headers: [String : String]?
  internal var filters: [Filter]?
  
  private var operationQueue: OperationQueue!
  

  // MARK: - Public properties
  public var imageCacheMode: ImageCacheMode = .Processed
  public var cacheLimit: Int = 50 {
    didSet {
      self.imageCache.countLimit = self.cacheLimit
    }
  }
  
  
  // MARK: - Singleton
  public static let downloader: Ripper = {
    var instance: Ripper = Ripper()
    return instance
  }()
  
  
  // MARK: - Initialization
  public init() {
    // initialize the shared http client
    var clientConfiguration: HttpClientConfiguration = HttpClientConfiguration()
    clientConfiguration.timeoutInterval = 60.0
    self.httpClient = HttpClient(configuration: clientConfiguration)

    initialize()  // common initialization
  }
  
  public init(httpConfiguration: HttpClientConfiguration) {
    self.httpClient = HttpClient(configuration: httpConfiguration)
    self.imageCache = NSCache()
    
    initialize()  // common initialization
  }
  
  private func initialize() {
    // initialize the image cache
    self.imageCache = NSCache()
    self.imageCache.countLimit = self.cacheLimit
    
    // initialize properties / defaults
    self.headers = [:]
    self.filters = []
    
    // initialize the operation queue
    self.operationQueue = OperationQueue(downloader: self)
  }

  
  // MARK: - Global operations / properties
  public func resizeFilter(width width: Double, height: Double) -> Ripper {
    self.resizeFilter = ScaleFilter()
    self.resizeFilter!.outputSize = CGSize(width: width, height: height)
    return self
  }

  public func placeholder(placeholderImage: UIImage) -> Ripper {
    self.placeholderImage = placeholderImage
    return self
  }
  
  public func HTTPHeaders(headers: [String : String]) -> Ripper {
    self.headers = headers
    return self
  }
  
  public func addHeader(key key: String, value: String) -> Ripper {
    if self.headers != nil {
      self.headers![key] = value
    }
    return self
  }
  
  public func addFilter(filter: Filter) -> Ripper {
    if self.filters != nil {
      self.filters!.append(filter)
    }
    return self
  }

  
  // MARK: - Operation creation
  public func load(url url: String) -> Operation {
    return self.operationQueue.makeOperation(url: url, named: nil)
  }
  
  public func load(named named: String) -> Operation {
    return self.operationQueue.makeOperation(url: nil, named: named)
  }
  
  
}
