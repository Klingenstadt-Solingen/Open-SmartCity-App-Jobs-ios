//
//  OSCAImageFileDataRequestResource.swift
//  OSCAJobs
//
//  Created by Mammut Nithammer on 27.07.22.
//

import Foundation
import OSCAEssentials
import OSCANetworkService

extension OSCAImageDataRequestResource {
  /// OSCAImageFileDataRequestResource for press releases image
  /// - Parameters:
  ///    - objectId: The id of a PressRelease
  ///    - baseURL: The URL to the file
  ///    - fileName: The name of the file
  ///    - mimeType: The filename extension
  /// - Returns: A ready to use OSCAImageFileDataRequestResource
  static func jobPostingImageData(objectId: String, baseURL: URL, fileName: String, mimeType: String) -> OSCAImageDataRequestResource<OSCAJobPostingImageData> {
    return OSCAImageDataRequestResource<OSCAJobPostingImageData>(
      objectId: objectId,
      baseURL: baseURL,
      fileName: fileName,
      mimeType: mimeType)
  }
}

