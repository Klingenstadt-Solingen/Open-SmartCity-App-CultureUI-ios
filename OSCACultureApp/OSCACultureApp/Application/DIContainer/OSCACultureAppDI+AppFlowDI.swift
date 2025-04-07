//
//  OSCACultureAppDI+AppFlowDI.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import UIKit
import OSCAEssentials

extension OSCACultureAppDI {
  final class AppFlowDI {
    let dependencies: OSCACultureAppDI.AppFlowDI.Dependencies
    
    var appFlow: OSCACultureAppFlow?
    
    init(dependencies: OSCACultureAppDI.AppFlowDI.Dependencies) {
      self.dependencies = dependencies
    }// end init
  }// end final class AppFlowDI
}// end extension final class AppFlowDI

// MARK: - Dependencies
extension OSCACultureAppDI.AppFlowDI {
  struct Dependencies {
    let appDI: OSCACultureAppDI
  }// end struct Dependencies
}// end extension final class AppFlowDI

// MARK: - OSCACultureApp flow
extension OSCACultureAppDI.AppFlowDI {
  func makeAppFlowDependencies(window: UIWindow,
                               onDismissed: (() -> Void)?) -> OSCACultureAppFlow.Dependencies {
    let dependencies: OSCACultureAppFlow.Dependencies = OSCACultureAppFlow.Dependencies(appDI: dependencies.appDI,
                                                                                  window: window,
                                                                                  onDismissed: onDismissed)
    return dependencies
  }// end func makeAppFlowDependencies
  
  /// singleton `OSCACultureAppFlow`
  func makeOSCACultureAppFlow(window: UIWindow,
                              onDismissed: (() -> Void)?) -> OSCACultureAppFlow {
    if let appFlow = appFlow {
      return appFlow
    } else {
      let dependencies = makeAppFlowDependencies(window: window,
                                                 onDismissed: onDismissed)
      let flow = OSCACultureAppFlow(dependencies: dependencies)
      appFlow = flow
      return flow
    }// end if
  }// end func makeOSCACultureAppFlow
}// end extension final class AppFlowDI

extension OSCACultureAppDI.AppFlowDI {
  func makeNavigationController(window: UIWindow) -> UINavigationController {
    guard let rootViewController = window.rootViewController,
          let navigationController = rootViewController as? UINavigationController
    else {
#warning("TODO: fatalError")
      fatalError("window's rootViewController is not properly initialized!")
    }
    return navigationController
  }// end func makeNavigationController
  
  func makeNavigationRouter(navigationController: UINavigationController) -> NavigationRouter {
    let router = NavigationRouter(navigationController: navigationController)
    return router
  }// end func makeNavigationRouter
}// end extension final class AppFlowDI
