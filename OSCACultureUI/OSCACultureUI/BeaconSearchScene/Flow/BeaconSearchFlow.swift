//
//  BeaconSearchFlow.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import UIKit
import OSCACulture
import OSCAEssentials

protocol BeaconSearchDependencies {
  var deeplinkScheme: String { get }
  func makeBeaconSearchViewController(actions: BeaconSearchViewModel.Actions) -> BeaconSearchViewController
  func makeOSCASafariViewFlowCoordinator(router: Router,
                                         url: URL) -> Coordinator
}// end protocol BeaconSearchDependencies

protocol BeaconDetailsDependencies {
  func makeBeaconDetailsViewController(actions: BeaconDetailsViewModel.Actions,
                                       artWaldBeacon: OSCAArtWald) -> BeaconDetailsViewController
}// end protocol BeaconDetailsDependencies

protocol BeaconImageDetailsDependencies {
  func makeBeaconImageDetailsViewController(actions: BeaconImageDetailsViewModel.Actions,
                                            urls: [URL]) -> BeaconImageDetailsViewController
}// end protocol BeaconImageDetailsDependencies

protocol BeaconSearchFlowDependencies: BeaconSearchDependencies,
                                       BeaconDetailsDependencies,
                                       BeaconImageDetailsDependencies{}

public final class BeaconSearchFlow: Coordinator {
  public var children: [Coordinator] = []
  public var router: Router
  let dependencies: BeaconSearchFlowDependencies
  
  weak var beaconSearchVC: BeaconSearchViewController?
  weak var beaconDetailsVC: BeaconDetailsViewController?
  weak var beaconImageDetailsVC: BeaconImageDetailsViewController?
  weak var webViewFlow: Coordinator?
  
  init(router: Router,
       dependencies: BeaconSearchFlowDependencies) {
    self.router = router
    self.dependencies = dependencies
  }// end init
  
  public func present(animated: Bool,
               onDismissed: (() -> Void)?) -> Void {
    showBeaconSearch( animated: animated,
                      onDismissed: onDismissed )
  }// end func present
}// end final class BeaconSearchFlow

// MARK: - BeaconSearch
extension BeaconSearchFlow {
  private func dismiss() -> Void {
    if let webViewFlow = webViewFlow {
      removeChild(webViewFlow)
    }// end if
    if !children.isEmpty {
      for child in children {
        removeChild(child)
      }// for each
    }// end if
    router.dismiss(animated: true)
  }// end func dismiss
  
  private func showWebsite(_ url: URL) -> Void {
    if let webViewFlow = webViewFlow {
      removeChild(webViewFlow)
      self.webViewFlow = nil
    }// end if
    let flow = dependencies
      .makeOSCASafariViewFlowCoordinator(router: router,
                                         url: url)
    presentChild(flow,
                 animated: true)
    webViewFlow = flow
  }// end private func showWebsite with url
  
  private func openDeviceSettings() -> Void {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
    
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl, completionHandler: { [weak self] success in
        guard let `self` = self else { return }
        print("Settings opened: \(success)")
        if let vc = self.beaconSearchVC {
          vc.didOpenDeviceSettings()
        }
      })
    }// end if
  }// end private func openDeviceSettings
  
  func showBeaconSearch(animated: Bool,
                                onDismissed: (() -> Void)?) -> Void {
    if let vc = beaconSearchVC {
      router.present(vc,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      let actions = BeaconSearchViewModel.Actions(showDetails: showDetail(artWaldBeacon:),
                                                  showWebView: showWebsite(_:),
                                                  dismiss:     dismiss,
                                                  openDeviceSettings: openDeviceSettings)
      let vc = dependencies
        .makeBeaconSearchViewController(actions: actions)
      router.present(vc,
                     animated: animated,
                     onDismissed: onDismissed)
      beaconSearchVC = vc
    }// end if
  }// end func showBeaconSearch
}// end extension final class BeaconSearchFlow

// MARK: - BeaconDetail
extension BeaconSearchFlow {
  private func showDetail(artWaldBeacon: OSCAArtWald) -> Void {
    guard let uuid = artWaldBeacon.uUID,
          let major = artWaldBeacon.major,
          let minor = artWaldBeacon.minor
    else { return }
#if DEBUG
    print("Beacon: UUID: \(uuid), major: \(major), minor: \(minor)")
#endif
    let actions = BeaconDetailsViewModel.Actions(showWebsite: showWebsite(_:),
                                                 showImageGallery: showImageGallery(imageURLs:),
                                                 showTitleImage: showTitleImage(imageURL:),
                                                 dismissDetail: dismissImageDetail)
    let vc = dependencies
      .makeBeaconDetailsViewController(actions: actions,
                                       artWaldBeacon: artWaldBeacon)
    router.present(vc,
                   animated: true,
                   onDismissed: nil)
    beaconDetailsVC = vc
  }// end private func showDetail with beacon
}// end extension final class BeaconSearchFlow

// MARK: - BeaconImageDetail
extension BeaconSearchFlow {
  private func showImageView(imageURLs: [URL],
                             animated: Bool,
                             onDismissed: (() -> Void)? = nil) -> Void {
    let actions = BeaconImageDetailsViewModel.Actions(dismissImageDetail: dismissImageDetail)
    let vc = dependencies
      .makeBeaconImageDetailsViewController(actions: actions,
                                            urls: imageURLs)
    router.presentModalViewController(vc,
                                      animated: animated,
                                      onDismissed: onDismissed)
    beaconImageDetailsVC = vc
  }// end private func showImageView
  
  private func showTitleImage(imageURL: URL) -> Void {
#if DEBUG
    print("Title image URL: \(imageURL.absoluteString)")
#endif
    showImageView(imageURLs: [imageURL],
                  animated: true)
  }// end private func showTitleImage
  
  private func showImageGallery(imageURLs: [URL]) -> Void {
#if DEBUG
    print("ImageGallery URL count: \(imageURLs.count)")
#endif
    showImageView(imageURLs: imageURLs,
                  animated: true)
  }// end private func showImageGallery
  
  private func dismissImageDetail() -> Void {
    if let _ = beaconImageDetailsVC {
      router.navigateBack(animated: true)
      self.beaconImageDetailsVC = nil
    }// end if
  }// end private func dismissImageDetail
}// end extension final class BeaconSearchFlow

extension BeaconSearchFlow {
  /**
   add `child` `Coordinator`to `children` list of `Coordinator`s and present `child` `Coordinator`
   */
  public func presentChild(_ child: Coordinator,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) {
    self.children.append(child)
    child.present(animated: animated) { [weak self, weak child] in
      guard let self = self, let child = child else { return }
      self.removeChild(child)
      onDismissed?()
    } // end on dismissed closure
  } // end public func presentChild
  
  private func removeChild(_ child: Coordinator) {
    /// `children` includes `child`!!
    guard let index = children.firstIndex(where: { $0 === child }) else { return } // end guard
    children.remove(at: index)
  } // end private func removeChild
} // end extension final class BeaconSearchFlow

