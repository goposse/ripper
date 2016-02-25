//
//  UIImage+Ripper.swift
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

public extension UIImage {
  
  // MARK: - Scaling functions
  public func scale(longestSide longestSide: Double) -> UIImage? {
    return scale(longestSide: longestSide, scaleUp: true)
  }
  
  public func scale(longestSide longestSide: Double, scaleUp: Bool) -> UIImage? {
    let imageSize: CGSize = self.size
    let maxSide: Double = fmax(Double(imageSize.width), Double(imageSize.height))
    let scaleFactor: Double = longestSide / maxSide
    if (!scaleUp && scaleFactor > 1.0) {
      return self
    } else {
      return self.scale(percentage: scaleFactor)
    }
  }
  
  public func scale(percentage percentage: Double) -> UIImage? {
    var imageSize: CGSize = self.size
    let cgPercentage = CGFloat(percentage)
    imageSize.width *= cgPercentage
    imageSize.height *= cgPercentage
    return scale(size: imageSize, scaleUp: true)
  }
  
  public func scale(size size: CGSize) -> UIImage? {
    return scale(size: size, scaleUp: true)
  }
  
  public func scale(size size: CGSize, scaleUp: Bool) -> UIImage? {
    let imageSize: CGSize = self.size
    if CGSizeEqualToSize(size, CGSizeZero) {
      return self
    }
    if !scaleUp && (size.width > imageSize.width || size.height > imageSize.height) {
      return self
    } else {
      let cgImage = self.CGImage
      var scaledImage: UIImage? = UIImage(CGImage: cgImage!, scale: 0.0, orientation: self.imageOrientation)
      if scaledImage != nil {
        var w: CGFloat = size.width, h: CGFloat = size.height
        if w == 0.0 {
          w = (size.height / imageSize.height) * imageSize.width
        } else if h == 0.0 {
          h = (size.width / imageSize.width) * imageSize.height
        }
        let outSize: CGSize = CGSize(width: w, height: h)
        let outRect: CGRect = CGRect(x: 0.0, y: 0.0, width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(outSize, false, 0.0)
        scaledImage!.drawInRect(outRect)
        scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
      }
    }
    return nil
  }
  
}
