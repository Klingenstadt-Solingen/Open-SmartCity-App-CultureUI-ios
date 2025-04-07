//
//  OSCACultureUITests.swift
//  OSCACultureUITests
//
//  Created by Stephan Breidenbach on 21.09.22.
//

#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import OSCAEssentials
import OSCACulture
@testable import OSCACultureUI
import OSCANetworkService
import OSCATestCaseExtension
import XCTest

final class OSCACultureUITests: XCTestCase {
  static let moduleVersion = "1.1.1"
  override func setUpWithError() throws {
    try super.setUpWithError()
  } // end override fun setUp
  
  func testModuleInit() throws {
    let uiModule = try makeDevUIModule()
    XCTAssertNotNil(uiModule)
    XCTAssertEqual(uiModule.version, OSCACultureUITests.moduleVersion)
    XCTAssertEqual(uiModule.bundlePrefix, "de.osca.culture.ui")
    let bundle = OSCACulture.bundle
    XCTAssertNotNil(bundle)
    let uiBundle = OSCACultureUI.bundle
    XCTAssertNotNil(uiBundle)
    let configuration = OSCACultureUI.configuration
    XCTAssertNotNil(configuration)
    XCTAssertNotNil(devPlistDict)
    XCTAssertNotNil(productionPlistDict)
  } // end func testModuleInit
  
  func testCultureUIConfiguration() throws {
    _ = try makeDevUIModule()
    let uiModuleConfig = try makeUIModuleConfig()
    XCTAssertEqual(OSCACultureUI.configuration.title, uiModuleConfig.title)
    XCTAssertEqual(OSCACultureUI.configuration.colorConfig.accentColor, uiModuleConfig.colorConfig.accentColor)
    XCTAssertEqual(OSCACultureUI.configuration.fontConfig.bodyHeavy, uiModuleConfig.fontConfig.bodyHeavy)
  } // end func testEventsUIConfiguration
} // end finla Class OSCATemplateTests

// MARK: - factory methods

extension OSCACultureUITests {
  func makeDevModuleDependencies() throws -> OSCACulture.Dependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults = try makeUserDefaults(domainString: "de.osca.culture.ui")
    let dependencies = OSCACulture.Dependencies(
      networkService: networkService,
      userDefaults: userDefaults
    )
    return dependencies
  } // end public func makeDevModuleDependencies
  
  func makeDevModule() throws -> OSCACulture {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCACulture.create(with: devDependencies)
    return module
  } // end public func makeDevModule
  
  func makeProductionModuleDependencies() throws -> OSCACulture.Dependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults = try makeUserDefaults(domainString: "de.osca.culture.ui")
    let dependencies = OSCACulture.Dependencies(
      networkService: networkService,
      userDefaults: userDefaults
    )
    return dependencies
  } // end public func makeProductionModuleDependencies
  
  func makeProductionModule() throws -> OSCACulture {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCACulture.create(with: productionDependencies)
    return module
  } // end public func makeProductionModule
  
  func makeUIModuleConfig() throws -> OSCACultureUI.Config {
    OSCACultureUI.Config(
      title: "OSCACultureUI",
      fontConfig: OSCAFontSettings(),
      colorConfig: OSCAColorSettings()
    )
  } // end public func makeUIModuleConfig
  
  func makeDevUIModuleDependencies() throws -> OSCACultureUI.Dependencies {
    let module = try makeDevModule()
    let uiConfig = try makeUIModuleConfig()
    return OSCACultureUI.Dependencies(
      moduleConfig: uiConfig,
      dataModule: module
    )
  } // end public func makeDevUIModuleDependencies
  
  func makeDevUIModule() throws -> OSCACultureUI {
    let devDependencies = try makeDevUIModuleDependencies()
    // init ui module
    let uiModule = OSCACultureUI.create(with: devDependencies)
    return uiModule
  } // end public func makeUIModule
  
  func makeProductionUIModuleDependencies() throws -> OSCACultureUI.Dependencies {
    let module = try makeProductionModule()
    let uiConfig = try makeUIModuleConfig()
    return OSCACultureUI.Dependencies(
      moduleConfig: uiConfig,
      dataModule: module
    )
  } // end public func makeProductionUIModuleDependencies
  
  func makeProductionUIModule() throws -> OSCACultureUI {
    let productionDependencies = try makeProductionUIModuleDependencies()
    // init ui module
    let uiModule = OSCACultureUI.create(with: productionDependencies)
    return uiModule
  } // end public func makeProductionUIModule
} // end extension OSCACultureUITests
#endif
