//
//  OSCAJobPosting.swift
//  OSCAJobs
//
//  Created by Mammut Nithammer on 27.07.22.
//

import Foundation
import OSCAEssentials

/// Object representing a press release
public struct OSCAJobPosting: OSCAParseClassObject, Equatable {
    /// ObjectId of the press release
    public private(set) var objectId: String?
    /// When the object was created.
    public private(set) var createdAt: Date?
    /// When the object was last updated.
    public private(set) var updatedAt: Date?
    /// The organization that posted the job offer
    public private(set) var hiringOrganization: OSCAJobsHiringOrganization?
    /// Title of the job posting
    public private(set) var title: String?
    /// URL to the web version of the job posting
    public private(set) var url: String?
    /// Date when the job offer was posted
    public private(set) var datePosted: Date?
    /// Type of the employment (e.g. full-time)
    public private(set) var employmentType: OSCAJobsEmploymentType?
    /// The id from elastic search, which is identical to the `objectId`
    public var _id: String?
}

public struct OSCAJobsHiringOrganization: Codable, Hashable, Equatable {
    /// name of the organization
    public private(set) var name: String?
    /// URL to the image of the organization
    public private(set) var imageUrl: String?
    /// Branch of the organization
    public private(set) var branch: String?
}

public enum OSCAJobsEmploymentType: String, Codable {
    case fullTime = "full-time"
    case partTime = "part-time"
    case contract
}

extension OSCAJobPosting {
  /// Parse class name
  public static var parseClassName : String { return "JobPosting" }
}// end extension OSCAJobPosting
