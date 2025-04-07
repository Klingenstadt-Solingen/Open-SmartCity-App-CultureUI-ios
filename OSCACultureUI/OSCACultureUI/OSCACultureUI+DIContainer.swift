//
//  OSCACultureUI+DIContainer.swift
//  OSCACultureUI
//
//  Created by Stephan Breidenbach on 29.09.22.
//

import OSCAEssentials
import OSCANetworkService
import UIKit
import OSCACulture
import OSCASafariView

extension OSCACultureUI {
  final class DIContainer {
    // MARK: Lifecycle
    
    public init(dependencies: OSCACultureUI.Dependencies) {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      // init ui module dependencies
      self.dependencies = dependencies
    } // end public init
    
    // MARK: Internal
    var beaconSearchFlow: BeaconSearchFlow?
    // MARK: Private
    let dependencies: OSCACultureUI.Dependencies
  } // end final class DIContainer
} // end final class OSCACultureUI

// MARK: - OSCACulture module
extension OSCACultureUI.DIContainer {
  func makeOSCACultureModule() -> OSCACulture {
    dependencies.dataModule
  } // end func makeOSCAEventsModule
  
  func makeCultureUIConfig() -> OSCACultureUI.Config {
    OSCACultureUI.configuration
  } // end makeCultureUIConfig
  
  func makeCultureUIColorConfig() -> OSCAColorSettings {
    guard let colorSettings = OSCACultureUI.configuration.colorConfig as? OSCAColorSettings
    else { return OSCAColorSettings() }
    return colorSettings
  } // end func makeCultureUIColorConfig
  
  func makeCultureUIFontConfig() -> OSCAFontSettings {
    guard let fontSettings = OSCACultureUI.configuration.fontConfig as? OSCAFontSettings
    else { return OSCAFontSettings() }
    return fontSettings
  } // end func makeCultureUIFontConfig
} // end extension final class OSCACultureUI.DIContainer

// MARK: - WebView module
extension OSCACultureUI.DIContainer {
  // MARK: - Feature UI Module Color settings
  private func makeOSCASafariViewColorSettings() -> OSCAColorSettings {
    return OSCAColorSettings()
  }// end func makeOSCASafariViewColorSettings
  
  // MARK: - Feature UI Module Type face settings
  private func makeOSCASafariViewFontSettings() -> OSCAFontSettings {
    return OSCAFontSettings()
  }// end func makeOSCASafariViewFontSettings
  
  // MARK: - Feature UI Module Config
  private func makeOSCASafariViewConfig() -> OSCASafariView.Config {
    return OSCASafariView.Config(title: "OSCASafariView",
                                 fontConfig: makeOSCASafariViewFontSettings(),
                                 colorConfig: makeOSCASafariViewColorSettings())
  }// end func makeOSCASafariViewConfig
  
  // MARK: - Feature UI Module dependencies
  private func makeOSCASafariViewModuleDependencies() -> OSCASafariView.Dependencies {
    return OSCASafariView.Dependencies(moduleConfig: makeOSCASafariViewConfig())
  }// end func makeOSCASafariViewModuleDependencies
  
  // MARK: - Feature UI Module
  private func makeOSCASafariViewModule() -> OSCASafariView {
    let dependencies = makeOSCASafariViewModuleDependencies()
    return OSCASafariView.create(with: dependencies)
  }// end func makeOSCASafariViewModule
}// end extension public final class DIContainer

// MARK: - Feature UI Module Flow Coordinators
extension OSCACultureUI.DIContainer {
  func makeOSCASafariViewFlowCoordinator(router: Router, url: URL) -> Coordinator {
    let flow = makeOSCASafariViewModule()
      .getSafariViewFlowCoordinator(router: router, url: url)
    return flow
  }// end func makeOSCASafariViewFlowCoordinator
}// end extension final class DIContainer


extension OSCACultureUI.DIContainer{
  struct Dependencies {
    let diContainer: OSCACultureUI.DIContainer
    let dataModule: OSCACulture
    let analyticsModule: OSCAAnalyticsModule? = nil
  }// end struct Dependencies
}// end extension final class OSCACultureUI.DIContainer

extension OSCACultureUI.DIContainer {
  func makeBeaconSearchViewController(actions: BeaconSearchViewModel.Actions) -> BeaconSearchViewController {
    let viewModel = makeBeaconSearchViewModel(actions: actions)
    let vc = BeaconSearchViewController.create(with: viewModel)
    return vc
  }// end func makeBeaconSearchViewController
  
  func makeBeaconSearchViewModelDependencies() -> BeaconSearchViewModel.Dependencies {
    let dataModule = dependencies
      .dataModule
    let colorConfig = makeCultureUIColorConfig()
    let fontConfig = makeCultureUIFontConfig()
    let dependencies = BeaconSearchViewModel.Dependencies(dataModule: dataModule,
                                                          colorConfig: colorConfig,
                                                          fontConfig: fontConfig)
    return dependencies
  }// end func makeBeaconSearchViewModelDependencies
  
  func makeBeaconSearchViewModel(actions: BeaconSearchViewModel.Actions) -> BeaconSearchViewModel {
    let dependencies = makeBeaconSearchViewModelDependencies()
    let viewModel = BeaconSearchViewModel(actions: actions,
                                          dependencies: dependencies)
    return viewModel
  }// end func makeBeaconSearchViewModel
}// end extension final class BeaconSceneDI

// MARK: - BeaconSearchDependencies conformance
extension OSCACultureUI.DIContainer: BeaconSearchDependencies {
}// end extension final class DIContainer

// MARK: - BeaconDetailsDependencies conformance
extension OSCACultureUI.DIContainer: BeaconDetailsDependencies {
  func makeBeaconDetailsViewController(actions: BeaconDetailsViewModel.Actions,
                                       artWaldBeacon: OSCAArtWald) -> BeaconDetailsViewController {
    let viewModel = makeBeaconDetailsViewModel(actions: actions,
                                               artWaldBeacon: artWaldBeacon)
    let vc = BeaconDetailsViewController.create(with: viewModel)
    return vc
  }// end func makeBeaconDetailsViewController
  
  func makeBeaconDetailsViewModelDependencies() -> BeaconDetailsViewModel.Dependencies {
    let dataModule = dependencies
      .dataModule
    let colorConfig = makeCultureUIColorConfig()
    let fontConfig = makeCultureUIFontConfig()
    let dependencies = BeaconDetailsViewModel.Dependencies(dataModule: dataModule,
                                                           colorConfig: colorConfig,
                                                           fontConfig: fontConfig)
    return dependencies
  }// end func makeBeaconDetailsViewModelDependencies
  
  func makeBeaconDetailsViewModel(actions: BeaconDetailsViewModel.Actions,
                                  artWaldBeacon: OSCAArtWald) -> BeaconDetailsViewModel {
    let dependencies = makeBeaconDetailsViewModelDependencies()
    let viewModel = BeaconDetailsViewModel( artWaldBeacon: artWaldBeacon,
                                            actions: actions,
                                            dependencies: dependencies)
    return viewModel
  }// end func makeBeaconDetailsViewModel
}// end extension final class BeaconSceneDI

// MARK: - BeaconImageDetailsDependencies conformance
extension OSCACultureUI.DIContainer: BeaconImageDetailsDependencies {
  func makeBeaconImageDetailsViewController(actions: BeaconImageDetailsViewModel.Actions,
                                            urls: [URL]) -> BeaconImageDetailsViewController {
    let viewModel = makeBeaconImageDetailsViewModel(actions: actions,
                                                    urls: urls)
    let vc = BeaconImageDetailsViewController.create(with: viewModel)
    return vc
  }// end func makeBeaconImageDetailsViewController
  
  func makeBeaconImageDetailsViewModelDependencies() -> BeaconImageDetailsViewModel.Dependencies {
    let dataModule = dependencies
      .dataModule
    let colorConfig = makeCultureUIColorConfig()
    let fontConfig = makeCultureUIFontConfig()
    let dependencies = BeaconImageDetailsViewModel.Dependencies(dataModule: dataModule,
                                                                colorConfig: colorConfig,
                                                                fontConfig: fontConfig)
    return dependencies
  }// end func makeBeaconImageDetailsViewModelDependencies
  
  func makeBeaconImageDetailsViewModel(actions: BeaconImageDetailsViewModel.Actions,
                                       urls: [URL]) -> BeaconImageDetailsViewModel {
    let dependencies = makeBeaconImageDetailsViewModelDependencies()
    let viewModel = BeaconImageDetailsViewModel( urls: urls,
                                                 actions: actions,
                                                 dependencies: dependencies)
    return viewModel
  }// end func makeBeaconImageDetailsViewModel
}// end extension final class BeaconSceneDI

extension OSCACultureUI.DIContainer: BeaconSearchFlowDependencies {
  /// singleton flow
  func makeBeaconSearchFlow(router: Router) -> BeaconSearchFlow {
    if let beaconSearchFlow = beaconSearchFlow {
      return beaconSearchFlow
    } else {
      let dependencies: BeaconSearchFlowDependencies = self
      let flow = BeaconSearchFlow(router: router,
                                  dependencies: dependencies)
      beaconSearchFlow = flow
      return flow
    }// end if
  }// end func makeBeaconSearchFlow
}// end extension final class BeaconSceneDI
