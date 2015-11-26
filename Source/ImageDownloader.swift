//
//  ImageDownloader.swift
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


public class ImageDownloader {

  private var url: String?
  private var imageName: String?
  private var placeholderImage: UIImage?
  private var outputSize: CGSize = CGSizeZero

  private var imageCache: NSCache
  private var httpClient: HttpClient!
  private var requestsMap: [UIImageView : ImageFetcher] = [:]


  // MARK: - Properties
  public var cacheLimit: Int = 50 {
    didSet {
      self.imageCache.countLimit = self.cacheLimit
    }
  }


  // MARK: - Singleton
  public static let downloader: ImageDownloader = {
    var instance: ImageDownloader = ImageDownloader()
    return instance
  }()


  // MARK: - Initialization
  public init() {
    var clientConfiguration: HttpClientConfiguration = HttpClientConfiguration()
    clientConfiguration.timeoutInterval = 60.0
    self.httpClient = HttpClient(configuration: clientConfiguration)
    self.imageCache = NSCache()
    self.imageCache.countLimit = self.cacheLimit
  }

  public init(httpConfiguration: HttpClientConfiguration) {
    self.httpClient = HttpClient(configuration: httpConfiguration)
    self.imageCache = NSCache()
    self.imageCache.countLimit = self.cacheLimit
  }

  public func load(url url: String) -> ImageDownloader {
    self.url = url
    self.imageName = nil
    return self
  }

  public func load(named named: String) -> ImageDownloader {
    self.imageName = named
    self.url = nil
    return self
  }

  public func placeholder(placeholderImage: UIImage) -> ImageDownloader {
    self.placeholderImage = placeholderImage
    return self
  }

  public func resize(width width: Double, height: Double) -> ImageDownloader {
    self.outputSize = CGSize(width: width, height: height)
    return self
  }


  // MARK: - Download initialization
  public func into(imageView: UIImageView) {
    self.into(imageView, callback: nil)
  }

  public func into(imageView: UIImageView, callback: ImageCallback?) {
    self.cancelRequest(target: imageView)
    // Check if image is available in the cache
    var cachedImage: UIImage?
    if let imageUrl: String = self.url {
      if let image: UIImage = self.imageCache.objectForKey(imageUrl) as? UIImage {
        cachedImage = image
      }
    }

    if cachedImage != nil {
      // If cached image is available, set it and do the callback
      imageView.image = cachedImage
      if callback != nil {
        callback!(image: cachedImage, error: nil)
      }
    } else {
      // Otherwise, set the placeholder and fetch it
      imageView.image = self.placeholderImage

      let fetcher: ImageFetcher? = self.execute { (image: UIImage?, error: NSError?) -> Void in
        self.removeMapItem(target: imageView)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if error == nil && image != nil {
            imageView.image = image!
          }
          if callback != nil {
            callback!(image: image, error: error)
          }
        })
      }
      if fetcher != nil {
        self.requestsMap[imageView] = fetcher!
      }
    }
  }

  public func execute(callback: ImageCallback) -> ImageFetcher? {
    if let imageUrl: String = self.url {
      if let image: UIImage = self.imageCache.objectForKey(imageUrl) as? UIImage {
        callback(image: image, error: nil)
        return nil
      } else {
        let fetcher: ImageFetcher = ImageFetcher(httpClient: self.httpClient)
        fetcher.fetch(imageUrl: imageUrl, callback: { (image, error) -> Void in
          if image != nil {
            self.imageCache.setObject(image!, forKey: imageUrl)
          }
          callback(image: image, error: error)
        })
        return fetcher
      }
    } else if let imageName: String = self.imageName {
      var responseImage: UIImage?
      if let image: UIImage = UIImage(named: imageName) {
        responseImage = image.scale(size: self.outputSize)
      }
      callback(image: responseImage, error: nil)
    } else {
      callback(image: nil, error: nil)
    }
    return nil
  }

  private func removeMapItem(target imageView: UIImageView) -> ImageFetcher? {
    if let fetcher: ImageFetcher = self.requestsMap[imageView] {
      self.requestsMap.removeValueForKey(imageView)
      return fetcher
    }
    return nil
  }

  public func cancelRequest(target imageView: UIImageView) {
    if let fetcher: ImageFetcher = self.removeMapItem(target: imageView) {
      fetcher.cancel()
//      dispatch_async(dispatch_get_main_queue(), { () -> Void in
//        imageView.image = nil
//      })
    }
  }

}
