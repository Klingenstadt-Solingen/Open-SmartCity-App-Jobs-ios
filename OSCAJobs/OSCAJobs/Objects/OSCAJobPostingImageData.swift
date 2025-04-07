//
//  OSCAJobPostingImageData.swift
//  OSCAJobs
//
//  Created by Mammut Nithammer on 27.07.22.
//

import OSCAEssentials
import Foundation

public struct OSCAJobPostingImageData: OSCAImageData {
  
  public var objectId: String?
  public var imageData: Data?
  
  public init(objectId: String, imageData: Data) {
    self.objectId = objectId
    self.imageData = imageData
  }
  
  public static func < (lhs: OSCAJobPostingImageData, rhs: OSCAJobPostingImageData) -> Bool {
    let lhsImageData = lhs.imageData
    let rhsImageData = rhs.imageData
    if nil != lhsImageData {
      if nil != rhsImageData {
        return lhsImageData!.count < rhsImageData!.count
      } else {
        return false
      }
    } else {
      if nil != rhsImageData {
        return false
      } else {
        return true
      }
    }
  }
}

