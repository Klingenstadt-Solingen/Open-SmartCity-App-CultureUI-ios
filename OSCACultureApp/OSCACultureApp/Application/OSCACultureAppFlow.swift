//
//  OSCACultureAppFlow.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import UIKit
import OSCAEssentials
import OSCANetworkService

final class OSCACultureAppFlow {
  let dependencies: OSCACultureAppFlow.Dependencies
  var router: Router
  var navigationController: UINavigationController
  var children: [Coordinator] = []
  
  private weak var beaconSearchFlow: Coordinator?
  
  init(dependencies: OSCACultureAppFlow.Dependencies) {
    self.dependencies = dependencies
    let navController = dependencies
      .appDI
      .makeOSCACultureAppFlowDI()
      .makeNavigationController(window: dependencies.window)
    self.navigationController = navController
    // init router
    let navigationRouter = dependencies
      .appDI
      .makeOSCACultureAppFlowDI()
      .makeNavigationRouter(navigationController: navController)
    self.router = navigationRouter
  }// end init
  
  func showBeaconSearch (animated: Bool,
                         onDismissed: (() -> Void)?) -> Void {
    if let _ = beaconSearchFlow {
      
    } else {
      let flow = dependencies
        .appDI
        .makeUIModuleDI()
        .makeBeaconSearchFlow(router: router)
      flow.present(animated: animated,
                   onDismissed: onDismissed)
      beaconSearchFlow = flow
    }// end if
  }// end func showMain
  
  func present(animated: Bool,
               onDismissed: (() -> Void)?) -> Void {
    showBeaconSearch(animated: animated,
                     onDismissed: onDismissed)
  }// end func present
  
}// end final class OSCACultureAppFlow

extension OSCACultureAppFlow {
  struct Dependencies {
    let appDI: OSCACultureAppDI
    let window: UIWindow
    let onDismissed: (() -> Void)?
  }// end struct Dependencies
}// end extension OSCACultureAppFlow

extension OSCACultureAppFlow: Coordinator {}


