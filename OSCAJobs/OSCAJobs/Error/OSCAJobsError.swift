//
//  OSCAJobsError.swift
//  OSCAJobs
//
//  Created by Mammut Nithammer on 27.07.22.
//

import Foundation

public enum OSCAJobsError: Swift.Error, CustomStringConvertible {
    case networkInvalidRequest
    case networkInvalidResponse
    case networkDataLoading(statusCode: Int, data: Data)
    case networkJSONDecoding(error: Error)
    case networkIsInternetConnectionFailure
    case networkError

    public var description: String {
        switch self {
        case .networkInvalidRequest:
            return "There is a network Problem: invalid request!"
        case .networkInvalidResponse:
            return "There is a network Problem: invalid response!"
        case let .networkDataLoading(statusCode, data):
            return "There is a network Problem: data loading failed with status code \(statusCode): \(data)"
        case let .networkJSONDecoding(error):
            #if DEBUG
            return "There is a network Problem: JSON decoding: \(error.localizedDescription)"
            #endif
            return "There is a network Problem with JSON decoding"
        case .networkIsInternetConnectionFailure:
            return "There is a network Problem: Internet connection failure!"
        case .networkError:
            return "There is an unspecified network Problem!"
        } // end switch case
    } // end var description
} // end public enum OSCAJobsError

extension OSCAJobsError: Equatable {
    public static func == (lhs: OSCAJobsError, rhs: OSCAJobsError) -> Bool {
        switch (lhs, rhs) {
        case (.networkInvalidRequest, .networkInvalidRequest):
            return true
        case (.networkInvalidResponse, .networkInvalidResponse):
            return true
        case let (.networkDataLoading(statusCodeLhs, dataLhs), .networkDataLoading(statusCodeRhs, dataRhs)):
            let statusCode = statusCodeLhs == statusCodeRhs
            let data = dataLhs == dataRhs
            return statusCode && data
        case (networkJSONDecoding(_), networkJSONDecoding(_)):
            return true
        case (.networkIsInternetConnectionFailure, .networkIsInternetConnectionFailure):
            return true
        case (.networkError, .networkError):
            return true
        default:
            return false
        } // switch case
    } // public static func ==
} // end extension public enum OSCAJobsError
