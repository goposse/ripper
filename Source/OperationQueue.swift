//
//  OperationQueue.swift
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

internal class OperationQueue {
  
  private var targetOperationMap: [UIView : Operation]
  private var allOperations: [Operation]
  private var downloader: Ripper
  
  init(downloader downloader: Ripper) {
    self.downloader = downloader

    // initialize the operation tracking arrays / maps
    self.targetOperationMap = [:]
    self.allOperations = []
  }
  
  
  // MARK: - Operation creation
  internal func makeOperation(url url: String?, named: String?) -> Operation {
    
    let operation: Operation = Operation(operationQueue: self,
        downloader: self.downloader)
    
    operation.url = url
    operation.placeholderImage = self.downloader.placeholderImage
    
    if self.downloader.filters != nil {
      operation.filters = self.downloader.filters
    }
    if self.downloader.resizeFilter != nil {
      operation.filters = [ self.downloader.resizeFilter! ]
    }
    if self.downloader.headers != nil {
      operation.headers = self.downloader.headers
    }
    
    return operation
  }
  

  // MARK: - Operation management
  internal func registerOperation(operation operation: Operation) {
    guard let target = operation.target else {
      return
    }
    self.targetOperationMap[target] = operation
    self.allOperations.append(operation)
    print("")
  }
  
  public func cancel(operation operation: Operation) {
    operation.cancel()
  }
  
  public func cancelOperation(target target: UIImageView) {
    if let operation: Operation = self.targetOperationMap[target] {
      self.targetOperationMap.removeValueForKey(target)
      operation.cancel()
    }
  }
  
  internal func finishOperation(target: UIImageView) {
    self.targetOperationMap.removeValueForKey(target)
  }

  
}
