//
//  File.swift
//
//
//  Created by Mammut Nithammer on 27.07.22.
//

import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public struct OSCAJobsDependencies {
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  let analyticsModule: OSCAAnalyticsModule?

  public init(networkService: OSCANetworkService,
              userDefaults: UserDefaults,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.networkService = networkService
    self.userDefaults = userDefaults
    self.analyticsModule = analyticsModule
  } // end public memberwise init
} // end public struct OSCAPressReleasesDependencies

/// Module to handle press releases
public struct OSCAJobs: OSCAModule {
  /// module DI container
  var moduleDIContainer: OSCAJobsDIContainer!

  let transformError: (OSCANetworkError) -> OSCAJobsError = { networkError in
    switch networkError {
    case OSCANetworkError.invalidResponse:
      return OSCAJobsError.networkInvalidResponse
    case OSCANetworkError.invalidRequest:
      return OSCAJobsError.networkInvalidRequest
    case let OSCANetworkError.dataLoadingError(statusCode: code, data: data):
      return OSCAJobsError.networkDataLoading(statusCode: code, data: data)
    case let OSCANetworkError.jsonDecodingError(error: error):
      return OSCAJobsError.networkJSONDecoding(error: error)
    case OSCANetworkError.isInternetConnectionError:
      return OSCAJobsError.networkIsInternetConnectionFailure
    } // end switch case
  } // end let transformError
  /// Moduleversion
  public var version: String = "1.0.3"
  /// Bundle prefix of the module
  public var bundlePrefix: String = "de.osca.jobs"

  private var networkService: OSCANetworkService

  public private(set) var userDefaults: UserDefaults

  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!

  /**
   create module and inject module dependencies

   ** This is the only way to initialize the module!!! **
   - Parameter moduleDependencies: module dependencies
   ```
   call: OSCAPressReleases.create(with moduleDependencies)
   ```
   */
  public static func create(with moduleDependencies: OSCAJobsDependencies) -> OSCAJobs {
    var module: OSCAJobs = OSCAJobs(networkService: moduleDependencies.networkService,
                                    userDefaults: moduleDependencies.userDefaults)
    module.moduleDIContainer = OSCAJobsDIContainer(dependencies: moduleDependencies)

    return module
  } // end public static func create

  /// Initializes the press release module
  /// - Parameter networkService: Your configured network service
  private init(networkService: OSCANetworkService,
               userDefaults: UserDefaults) {
    self.networkService = networkService
    self.userDefaults = userDefaults
    var bundle: Bundle?
    #if SWIFT_PACKAGE
      bundle = Bundle.module
    #else
      bundle = Bundle(identifier: bundlePrefix)
    #endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  } // end init
} // end public struct OSCAPressReleases

extension OSCAJobs {
  /// Downloads press releases from parse-server
  /// - Parameter limit: Limits the amount of press releases that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: An array of press releases
  public func getJobPostings(limit: Int = 1000, query: [String: String] = ["order": "-date"]) -> AnyPublisher<Result<[OSCAJobPosting], Error>, Never> {
    var parameters = query
    parameters["limit"] = "\(limit)"

    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    return networkService
      .download(OSCAClassRequestResource.jobPosting(baseURL: networkService.config.baseURL, headers: headers, query: parameters))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<[OSCAJobPosting], Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }

  /// Downloads press releases image from parse-server
  /// - Parameters:
  ///    - objectId: The id of a PressRelease
  ///    - baseURL: The URL to the file
  ///    - fileName: The name of the file
  ///    - mimeType: The filename extension
  /// - Returns: An image data for a press release
  public func getJobPostingImage(objectId: String, baseURL: URL, fileName: String, mimeType: String) -> AnyPublisher<Result<OSCAJobPostingImageData, Error>, Never> {
    return networkService
      .fetch(OSCAImageDataRequestResource<OSCAJobPostingImageData>
        .jobPostingImageData(
          objectId: objectId,
          baseURL: baseURL,
          fileName: fileName,
          mimeType: mimeType))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<OSCAJobPostingImageData, Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }
} // end extension public struct OSCAPressReleases

// MARK: - elastic search

extension OSCAJobs {
  public typealias OSCAJobPostingPublisher = AnyPublisher<[OSCAJobPosting], OSCAJobsError>

  /// ```console
  /// curl -vX POST 'https://parse-dev.solingen.de/functions/elastic-search' \
  ///  -H "X-Parse-Application-Id: <APP_ID>" \
  ///  -H "X-Parse-Client-Key: <CLIENT_KEY>" \
  ///  -H 'Content-Type: application/json' \
  ///  -d '{"index":"press_releases","query":"Solingen"}'
  /// ```
  public func elasticSearch(for query: String, at index: String = "job_posting") -> OSCAJobPostingPublisher {
    guard !query.isEmpty,
          !index.isEmpty
    else {
      return Empty(completeImmediately: true,
                   outputType: [OSCAJobPosting].self,
                   failureType: OSCAJobsError.self).eraseToAnyPublisher()
    } // end guard
    // init cloud function parameter object
    let cloudFunctionParameter = ParseElasticSearchQuery(index: index,
                                                         query: query)

    var publisher: AnyPublisher<[OSCAJobPosting], OSCANetworkError>
    #if MOCKNETWORK

    #else
      var headers = networkService.config.headers
      if let sessionToken = userDefaults.string(forKey: "SessionToken") {
        headers["X-Parse-Session-Token"] = sessionToken
      }

      publisher = networkService.fetch(OSCAFunctionRequestResource<ParseElasticSearchQuery>
        .elasticSearch(baseURL: networkService.config.baseURL,
                       headers: headers,
                       cloudFunctionParameter: cloudFunctionParameter))
    #endif
    return publisher
      .mapError(transformError)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  } // end public func elasticSearch for query at index
} // end extension public struct OSCAPressRealeses
