//
//  OSCAClassRequestResource+OSCAJobPosting.swift
//  OSCAJobs
//
//  Created by Stephan Breidenbach on 15.07.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  static func jobPosting(baseURL: URL,
                         headers: [String: CustomStringConvertible],
                         query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource {
    let parseClass = OSCAJobPosting.parseClassName
    return OSCAClassRequestResource(baseURL: baseURL,
                                                      parseClass: parseClass,
                                                      parameters: query,
                                                      headers: headers)
  }// end static func jobPosting
}// end extension public struct OSCAClassRequestResource
