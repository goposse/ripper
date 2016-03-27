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


public class Ripper {
  
  // MARK: - Internal / private properties
  private var placeholderImage: UIImage?
  private var resizeFilter: ScaleFilter?
  private var httpClient: HttpClient!
  internal var targetOperationMap: [UIImageView : Operation]!
  internal var allOperations: [Operation]!
  internal var imageCache: NSCache
  
  
  // MARK: - Public properties
  public var headers: [String : String]?
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
    
    // initialize the image cache
    self.imageCache = NSCache()
    self.imageCache.countLimit = self.cacheLimit
    
    // initialize the operation tracking arrays / maps
    self.targetOperationMap = [:]
    self.allOperations = []
  }
  
  public init(httpConfiguration: HttpClientConfiguration) {
    self.httpClient = HttpClient(configuration: httpConfiguration)
    self.imageCache = NSCache()
    self.imageCache.countLimit = self.cacheLimit
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

  
  // MARK: - Operation creation
  public func load(url url: String) -> Operation {
    return makeOperation(url: url, named: nil)
  }
  
  public func load(named named: String) -> Operation {
    return makeOperation(url: nil, named: named)
  }
  
  private func makeOperation(url url: String?, named: String?) -> Operation {
    let operation: Operation = Operation(downloader: self, httpClient: self.httpClient)
    if self.resizeFilter != nil {
      operation.filters = [ self.resizeFilter! ]
    }
    operation.placeholderImage = self.placeholderImage
    return operation
  }
  
  
  // MARK: - Operation management
  public func cancelRequest(target target: UIImageView) {
    if let operation: Operation = self.targetOperationMap[target] {
      self.targetOperationMap.removeValueForKey(target)
      operation.cancel()
    }
  }
  
  public func finishOperation(target: UIImageView) {
    self.targetOperationMap.removeValueForKey(target)
  }
  
}
