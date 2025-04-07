//
//  OSCACultureUI.swift
//  OSCACultureUI
//
//  Created by Stephan Breidenbach on 29.09.22.
//

import Combine
import Foundation
import OSCAEssentials
import OSCACulture
import UIKit

// MARK: - OSCACultureUI
/// map ui module
public struct OSCACultureUI: OSCAModule {
  // MARK: Lifecycle
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  public init(with config: OSCAUIModuleConfig) {
#if SWIFT_PACKAGE
    // Self.bundle = .module
    Self.bundle = .module
#else
    guard let bundle = Bundle(identifier: bundlePrefix)
    else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCACultureUI.Config
    else { fatalError("Config couldn't be initialized!") }
    OSCACultureUI.configuration = extendedConfig
  } // end public init
  // MARK: Public
  
  ///  module configuration
  public internal(set) static var configuration: OSCACultureUI.Config!
  
  /// module `Bundle`
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  /// version of the module
  public var version: String = "1.1.1"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.culture.ui"
  
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCACultureUI.Dependencies) -> OSCACultureUI {
    var module = Self(with: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCACultureUI.DIContainer(dependencies: moduleDependencies)
    return module
  } // end public static func create
  
  public func getBeaconSearchFlow(router: Router) -> BeaconSearchFlow {
    let flow = moduleDIContainer.makeBeaconSearchFlow(router: router)
    return flow
  } // end public func getMapFlowCoordinator
  
  // MARK: Private
  
  /// module DI container
  private var moduleDIContainer: OSCACultureUI.DIContainer!
} // end public func OSCACultureUI

// MARK: - Dependencies
extension OSCACultureUI {
  public struct Dependencies {
    public init(moduleConfig: OSCACultureUI.Config,
                dataModule: OSCACulture,
                analyticsModule: OSCAAnalyticsModule? = nil
    ) {
      self.moduleConfig = moduleConfig
      self.dataModule = dataModule
      self.analyticsModule = analyticsModule
    }// end public memberwise init
    public let moduleConfig: OSCACultureUI.Config
    public let dataModule: OSCACulture
    public let analyticsModule: OSCAAnalyticsModule?
  }// end public struct OSCAMas
}// end extension public struct OSCACultureUI

// MARK: - Config
public protocol OSCACultureUIConfig: OSCAUIModuleConfig {
  /// typeface configuration
  var fontConfig: OSCAFontConfig { get set }
  /// color configuration
  var colorConfig: OSCAColorConfig { get set }
  /// default location
  var defaultLocation: OSCAGeoPoint { get set }
  ///  app deeplink scheme
  var deeplinkScheme: String { get set }
} // end public protocol OSCACultureUIConfig

public extension OSCACultureUI {
  /// The configuration of the `OSCACultureUI` module
  struct Config: OSCACultureUIConfig {
    // MARK: Lifecycle
    
    public init(
      title: String?,
      fontConfig: OSCAFontSettings,
      colorConfig: OSCAColorSettings,
      defaultLocation: OSCAGeoPoint = OSCAGeoPoint(latitude: 51.17724517968174, longitude: 7.084675786820801),
      deeplinkScheme: String = "solingen"
    ) {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      self.title = title
      self.fontConfig = fontConfig
      self.colorConfig = colorConfig
      self.deeplinkScheme = deeplinkScheme
      self.defaultLocation = defaultLocation
    } // end public memberwise init
    
    // MARK: Public
    
    /// module title
    public var title: String?
    /// `UIView` corner radius
    public var cornerRadius: Double = 20.0
    /// `UIView` border thickness
    public var borderThickness: Double = 1.5
    /// typeface configuration
    public var fontConfig: OSCAFontConfig
    /// color configuration
    public var colorConfig: OSCAColorConfig
    /// placeholder for category icon
    public var placeholderIcon: UIImage?
    /// default location
    public var defaultLocation: OSCAGeoPoint
    /// app deeplink scheme URL part before `://`
    public var deeplinkScheme: String = "solingen"
  } // end public struct Config
} // end extension public struct OSCACultureUI
