//
//  OSCACultureAppDI+SafariViewDI.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 23.09.22.
//

import OSCAEssentials
import OSCASafariView
import UIKit

extension OSCACultureAppDI {
  final class OSCASafariViewDI {
    // MARK: - Feature UI Module Color settings
    func makeOSCASafariViewColorSettings() -> OSCAColorSettings {
      return OSCAColorSettings()
    }// end func makeOSCASafariViewColorSettings
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCASafariViewFontSettings() -> OSCAFontSettings {
      return OSCAFontSettings()
    }// end func makeOSCASafariViewFontSettings
    
    // MARK: - Feature UI Module Config
    func makeOSCASafariViewConfig() -> OSCASafariView.Config {
      return OSCASafariView.Config(title: "OSCASafariView",
                                   fontConfig: makeOSCASafariViewFontSettings(),
                                   colorConfig: makeOSCASafariViewColorSettings())
    }// end func makeOSCASafariViewConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCASafariViewModuleDependencies() -> OSCASafariView.Dependencies {
      return OSCASafariView.Dependencies(moduleConfig: makeOSCASafariViewConfig())
    }// end func makeOSCASafariViewModuleDependencies
    
    // MARK: - Feature UI Module
    func makeOSCASafariViewModule() -> OSCASafariView {
      let dependencies = makeOSCASafariViewModuleDependencies()
      return OSCASafariView.create(with: dependencies)
    }// end func makeOSCASafariViewModule
  }// end final class OSCASafariViewDI
}// end extension public final class OSCACultureAppDI

// MARK: - Feature UI Module Flow Coordinators
extension OSCACultureAppDI.OSCASafariViewDI {
  /// singleton `Coordinator`
  func makeOSCASafariViewFlowCoordinator(url: URL, router: Router) -> Coordinator {
    let flow = makeOSCASafariViewModule()
      .getSafariViewFlowCoordinator(router: router, url: url)
    return flow
  }// end func makeOSCASafariViewFlowCoordinator
}// end extension final class OSCACultureAppDI
