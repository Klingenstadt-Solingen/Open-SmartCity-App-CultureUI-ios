//
//  OSCACultureAppDI.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import UIKit
import OSCAEssentials
import OSCANetworkService
import OSCACulture
import OSCACultureUI

final class OSCACultureAppDI {
  let appConfig: OSCACultureAppDI.Config!
  
  let _devNetworkService: OSCANetworkService!
  var devNetworkService: OSCANetworkService {
    if let devNetworkService = _devNetworkService {
      return devNetworkService
    } else {
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    }// end if
  }// end var devNetworkService
  
  let _productionNetworkService: OSCANetworkService!
  var productionNetworkService: OSCANetworkService {
    if let productionNetworkService = _productionNetworkService {
      return productionNetworkService
    } else {
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    }// end if
  }// end var productionNetworkService
  
  let _userDefaults: UserDefaults!
  var userDefaults: UserDefaults {
    if let userDefaults = _userDefaults {
      return userDefaults
    } else {
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    }// end if
  }// end var userDefaults
  
  let deeplinkScheme: String!
  
  var oscaCultureAppFlowDI: OSCACultureAppDI.AppFlowDI?
  var oscaCultureUIDI: OSCACultureUIDI?
  var oscaCultureDI: OSCACultureDI?
  var oscaSafariViewDI: OSCASafariViewDI?
  
  lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
  
  func getName() -> String {
    return "OSCACultureAppDI"
  }// end func getName
  
  private init(dependencies: OSCACultureAppDI.Dependencies) {
    appConfig = dependencies.appConfig
    _devNetworkService = dependencies.devNetworkService
    _productionNetworkService = dependencies.productionNetworkService
    _userDefaults = dependencies.userDefaults
    deeplinkScheme = dependencies.deeplinkScheme
  }// end private init
  
  static func create() -> OSCACultureAppDI {
    makeOSCAEssentialsModule()
    let appConfig = OSCACultureAppDI.Config()
    let userDefaults = OSCACultureAppDI.makeUserDefaults()
    let devNetworkService = OSCACultureAppDI.makeDevNetworkService(from: appConfig,
                                                                   with: userDefaults)
    let productionNetworkService = OSCACultureAppDI.makeProductionNetworkService(from: appConfig,
                                                                                 with: userDefaults)
    let appDeeplinkScheme = appConfig.deeplinkScheme
    let dependencies = OSCACultureAppDI.Dependencies(appConfig: appConfig,
                                                     devNetworkService: devNetworkService,
                                                     productionNetworkService: productionNetworkService,
                                                     userDefaults: userDefaults,
                                                     deeplinkScheme: appDeeplinkScheme)
    let appDI = OSCACultureAppDI(dependencies: dependencies)
    return appDI
  }// end static func create
}// end final class OSCACultureAppDI

extension OSCACultureAppDI {
  struct Dependencies {
    let appConfig: OSCACultureAppDI.Config
    let devNetworkService: OSCANetworkService
    let productionNetworkService: OSCANetworkService
    let userDefaults: UserDefaults
    let analyticsModule: OSCAAnalyticsModule? = nil
    let deeplinkScheme: String
  }// end struct Dependencies
}// end extension final class OSCACultureDI


extension OSCACultureAppDI {
  /// singleton `OSCACultureAppFlowDI`
  func makeOSCACultureAppFlowDI() -> OSCACultureAppDI.AppFlowDI {
    if let appFlowDI = oscaCultureAppFlowDI {
      return appFlowDI
    } else {
      let dependencies = OSCACultureAppDI.AppFlowDI.Dependencies(appDI: self)
      let appFlowDI = OSCACultureAppDI.AppFlowDI(dependencies: dependencies)
      oscaCultureAppFlowDI = appFlowDI
      return appFlowDI
    }// end if
  }// end func makeOSCACultureAppFlowDI
}// end extension final class OSCACultureAppDI

// MARK: - Essentials
#warning("Check for OSCAEssentials module creation place!")
extension OSCACultureAppDI {
  private static func makeOSCAEssentialsModule() {
    let _ = OSCAEssentials()
  }
}

// MARK: - network
extension OSCACultureAppDI {
  private static func makeDevNetworkService(from appConfiguration: OSCACultureAppDI.Config, with userDefaults: UserDefaults) -> OSCANetworkService {
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": appConfiguration.parseAPIKeyDev,
      "X-PARSE-APPLICATION-ID": appConfiguration.parseApplicationIDDev,
    ] // end headers
    let baseURL: URL? = URL(string: appConfiguration.parseAPIBaseURLDev)
    guard let baseURL = baseURL else {
      fatalError("Dev Parse API Root URL is not well formed for this environment")
    } // end guard
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    ) // end let config
    let dependencies = OSCANetworkServiceDependencies(config: config, userDefaults: userDefaults)
    let devNetworkService = OSCANetworkService.create(with: dependencies)
    return devNetworkService
  } // end private func makeDevNetworkService()
  
  private static func makeProductionNetworkService(from appConfiguration: OSCACultureAppDI.Config, with userDefaults: UserDefaults) -> OSCANetworkService {
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": appConfiguration.parseAPIKey,
      "X-PARSE-APPLICATION-ID": appConfiguration.parseApplicationID,
    ] // end headers
    let baseURL: URL? = URL(string: appConfiguration.parseAPIBaseURL)
    guard let baseURL = baseURL else {
      fatalError("Parse API Root URL is not well formed for this environment")
    } // end guard
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    ) // end let config
    let dependencies = OSCANetworkServiceDependencies(config: config, userDefaults: userDefaults)
    let productionNetworkService = OSCANetworkService.create(with: dependencies)
    return productionNetworkService
  } // end private func makeProductionNetworkService
} // end extension final class OSCACultureAppDI

// MARK: - UserDefaults
extension OSCACultureAppDI {
  private static func makeUserDefaults() -> UserDefaults {
    // TODO: - implementation of a non standard user default instance
    return UserDefaults.standard
  } // end var userDefaults
} // end extension final class OSCACultureAppDI

// MARK: - Configs
extension OSCACultureAppDI {
  func makeColorSettings() -> OSCAColorSettings {
    return OSCAColorSettings()
  }// end func makeColorSettings
  
  func makeTypefaceSettings() -> OSCAFontSettings {
    return OSCAFontSettings()
  }// end func makeTypefaceSettings
  
  func makeShadowSettings() -> OSCAShadowSettings {
    return OSCAShadowSettings(opacity: 0.3,
                              radius: 10,
                              offset: CGSize(width: 0, height: 2))
  }// end func makeShadowSettings
}// end extension final class OSCACultureAppDI

// MARK: - DI of Data Module
extension OSCACultureAppDI {
  func makeDataModuleDIDependencies() -> OSCACultureAppDI.OSCACultureDI.Dependencies {
    let dependencies: OSCACultureAppDI.OSCACultureDI.Dependencies = OSCACultureAppDI.OSCACultureDI.Dependencies(appDI: self, deeplinkScheme: deeplinkScheme)
    return dependencies
  }// end func makeDataModuleDIDependencies
  
  /// singleton data module `OSCACultureDI`
  func makeDataModuleDI() -> OSCACultureAppDI.OSCACultureDI {
    if let dataModuleDI = oscaCultureDI {
      return dataModuleDI
    } else {
      let dependencies = makeDataModuleDIDependencies()
      let dataModuleDI = OSCACultureAppDI.OSCACultureDI(dependencies: dependencies)
      oscaCultureDI = dataModuleDI
      return dataModuleDI
    }// end if
  }// end func makeDataModuleDI
}// end extension final class OSCACultureAppDI

// MARK: - DI of ui Module
extension OSCACultureAppDI {
  func makeUIModuleDIDependencies() -> OSCACultureAppDI.OSCACultureUIDI.Dependencies {
    let dataModule: OSCACulture = makeDataModuleDI()
      .makeSOCACulture()
    let dependencies: OSCACultureAppDI.OSCACultureUIDI.Dependencies =
    OSCACultureAppDI.OSCACultureUIDI.Dependencies(appDI: self,
                                                  dataModule: dataModule,
                                                  deeplinkScheme: deeplinkScheme)
    return dependencies
  }// end func makeUIModuleDIDependencies
  
  /// singleton ui module `OSCACultureUIDI`
  func makeUIModuleDI() -> OSCACultureAppDI.OSCACultureUIDI {
    if let uiModuleDI = oscaCultureUIDI {
      return uiModuleDI
    } else {
      let dependencies = makeUIModuleDIDependencies()
      let uiModuleDI = OSCACultureAppDI.OSCACultureUIDI(dependencies: dependencies)
      oscaCultureUIDI = uiModuleDI
      return uiModuleDI
    }// end if
  }// end func makeUIModuleDI
}// end extension final class OSCACultureAppDI



// MARK: - DI of Web view module
extension OSCACultureAppDI {
  /// singleton web module DI
  func makeWebViewModuleDI() -> OSCACultureAppDI.OSCASafariViewDI {
    if let webModuleDI = oscaSafariViewDI {
      return webModuleDI
    } else {
      let webModuleDI = OSCACultureAppDI.OSCASafariViewDI()
      oscaSafariViewDI = webModuleDI
      return webModuleDI
    }// end if
  }// end func makeWebViewModule
}// end extension final class OSCACultureAppDI
