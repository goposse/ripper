//
//  ImageFetcher.swift
//  Ripper
//
//  Created by Posse in NYC
//  http://goposse.com
//
//  Copyright (c) 2015 Posse Productions LLC.
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


// MARK: - Callbacks
public typealias ImageCallback = (image: UIImage?, error: NSError?) -> Void


public class ImageFetcher {
  
  public var dataTask: NSURLSessionDataTask!
  private (set) public var isCanceled: Bool = false
  private var httpClient: HttpClient!
  private var imageUrl: String!
  
  public init(httpClient: HttpClient) {
    self.httpClient = httpClient
  }
  
  public func fetch(imageUrl imageUrl: String, callback: ImageCallback) -> ImageFetcher {
    self.imageUrl = imageUrl
    var responseImage: UIImage?
    let request: Request = Request.Builder()
      .url(imageUrl)
      .method(Method.GET)
      .build()
    self.dataTask = self.httpClient.execute(request: request) { (response: Response?, error: NSError?) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if !self.isCanceled {
          if response != nil {
            if let data: NSData = response!.data {
              if let image: UIImage = UIImage(data: data) {
                responseImage = image
              }
            }
          }
          callback(image: responseImage, error: error)
        }
      })
    }
    return self
  }
  
  public func cancel() {
    self.isCanceled = true
  }
}

