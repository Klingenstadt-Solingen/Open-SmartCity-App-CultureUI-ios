//
//  OSCACultureAppDI+OSCACultureUIDI.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 29.09.22.
//

import Foundation
import OSCAEssentials
import OSCACultureUI
import OSCACulture

extension OSCACultureAppDI {
  final class OSCACultureUIDI {
    let dependencies: OSCACultureAppDI.OSCACultureUIDI.Dependencies
    
    var uiModule: OSCACultureUI?
    var beaconSearchFlow: BeaconSearchFlow?
    var dataModule: OSCACulture
    
    init(dependencies: OSCACultureAppDI.OSCACultureUIDI.Dependencies) {
      self.dependencies = dependencies
      self.dataModule = dependencies.dataModule
    }// end init
  }// end final class OSCACultureUIDI
}// end extension final class OSCACultureAppDI

extension OSCACultureAppDI.OSCACultureUIDI {
  struct Dependencies {
    let appDI: OSCACultureAppDI
    let dataModule: OSCACulture
    let deeplinkScheme: String
  }// end struct Dependencies
}// end extension final class OSCACultureUIDI

extension OSCACultureAppDI.OSCACultureUIDI {
  func makeOSCACultureUIConfig() -> OSCACultureUI.Config {
    let config = OSCACultureUI.Config(title: "OSCACultureUI",
                                      fontConfig: OSCAFontSettings(),
                                      colorConfig: OSCAColorSettings())
    return config
  }// end func makeOSCACultureUIConfig
  
  func makeOSCACultureUIDependencies() -> OSCACultureUI.Dependencies {
    let config = makeOSCACultureUIConfig()
    let dataModule = dependencies.dataModule
    let dependencies = OSCACultureUI.Dependencies(moduleConfig: config,
                                                  dataModule: dataModule)
    return dependencies
  }// end func makeOSCACultureUIDependencies
  
  /// singleton `OSCACultureUI`
  func makeOSCACultureUI() -> OSCACultureUI {
    if let module = uiModule {
      return module
    } else {
      let dependencies = makeOSCACultureUIDependencies()
      let module = OSCACultureUI.create(with: dependencies)
      uiModule = module
      return module
    }// end if
  }// end func makeSOCACultureUI
  
  /// singleton flow
  func makeBeaconSearchFlow(router: Router) -> BeaconSearchFlow {
    if let flow = beaconSearchFlow {
      return flow
    } else {
      let flow = makeOSCACultureUI()
        .getBeaconSearchFlow(router: router)
      beaconSearchFlow = flow
      return flow
    }// end if
  }// end makeBeaconSearchFlow
}// end extension final class OSCACultureAppDI
