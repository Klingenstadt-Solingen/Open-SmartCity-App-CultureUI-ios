//
//  OSCACultureAppDI+OSCACulture.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import Foundation
import OSCAEssentials
import OSCANetworkService
import OSCACulture

extension OSCACultureAppDI {
  final class OSCACultureDI {
    let dependencies: OSCACultureAppDI.OSCACultureDI.Dependencies
    
    var dataModule: OSCACulture?
    
    init(dependencies: OSCACultureAppDI.OSCACultureDI.Dependencies,
         dataModule: OSCACulture? = nil) {
      self.dependencies = dependencies
      self.dataModule = dataModule
    }// end init
  }// end final class OSCACultureDI
}// end extension final class OSCACultureAppDI

extension OSCACultureAppDI.OSCACultureDI {
  struct Dependencies {
    let appDI: OSCACultureAppDI
    let deeplinkScheme: String
  }// end struct Dependencies
}// end extension final class OSCACultureAppDI

extension OSCACultureAppDI.OSCACultureDI {
  func makeOSCACultureDependencies() -> OSCACulture.Dependencies {
    let networkService = dependencies
      .appDI
      .devNetworkService
    let userDefaults = dependencies
      .appDI
      .userDefaults
    let dependencies = OSCACulture.Dependencies(networkService: networkService,
                                                userDefaults: userDefaults)
    return dependencies
  }// end func makeOSCACultureDependencies
  
  /// singleton `OSCACulture`
  func makeSOCACulture() -> OSCACulture {
    if let module = dataModule {
      return module
    } else {
      let dependencies = makeOSCACultureDependencies()
      let module = OSCACulture.create(with: dependencies)
      dataModule = module
      return module
    }// end if
  }// end func makeSOCACulture
}// end extension final class OSCACultureAppDI
