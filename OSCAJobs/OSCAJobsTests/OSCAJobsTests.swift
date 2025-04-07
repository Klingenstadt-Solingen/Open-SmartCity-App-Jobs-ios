//
//  OSCAJobsTests.swift
//  OSCAJobsTests
//
//  Created by Stephan Breidenbach on 11.07.22.
//

#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import Combine
import OSCANetworkService
@testable import OSCAJobs
import OSCATestCaseExtension
import XCTest

final class OSCAJobsTests: XCTestCase {
  static let moduleVersion = "1.0.3"
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws -> Void {
    super.setUp()
    cancellables = []
  }// end override func setUp
  
  func testModuleInit() throws -> Void {
    let module = try makeDevModule()
    XCTAssertNotNil(module)
    XCTAssertEqual(module.version, OSCAJobsTests.moduleVersion)
    XCTAssertEqual(module.bundlePrefix, "de.osca.jobs")
    let bundle = OSCAJobs.bundle
    XCTAssertNotNil(bundle)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testDownload() throws -> Void {
    var pressReleases: [OSCAJobPosting] = []
    var error: Error?
    
    let jobsModule = try makeDevModule()
    
    let expectation = self.expectation(description: "GetJobPostings")
    
    jobsModule.getJobPostings(limit: 5)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }
      } receiveValue: { result in
        switch result {
        case let .success(objects):
          pressReleases = objects
        case let .failure(encounteredError):
          error = encounteredError
        }
      }
      .store(in: &cancellables)
    
    waitForExpectations(timeout: 10)
    
    XCTAssertNil(error)
    XCTAssertTrue(pressReleases.count == 5)
  }// end func testDownload
  
  func testElasticSearchForJobs() throws -> Void {
    var jobs: [OSCAJobPosting] = []
    let queryString = "Solingen"
    var error: Error?
    
    let expectation = self.expectation(description: "elasticSearchForJobs")
    let module = try makeDevModule()
    module.elasticSearch(for: queryString)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }// end switch case
      } receiveValue: { jobsFromNetwork in
        jobs = jobsFromNetwork
      }// end sink
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(error)
  }// end func testElasticSearchForPressReleases
}// end final class OSCAPressReleasesTests

// MARK: - factory methods
extension OSCAJobsTests {
  public func makeDevModuleDependencies() throws -> OSCAJobsDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.jobs")
    let dependencies = OSCAJobsDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCAJobs {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCAJobs.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCAJobsDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.jobs")
    let dependencies = OSCAJobsDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCAJobs {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCAJobs.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
}// end extension final class OSCAPressReleasesTests

#endif
