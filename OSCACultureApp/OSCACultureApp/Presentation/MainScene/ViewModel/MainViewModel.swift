//
//  MainViewModel.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import Foundation
import OSCACulture
import OSCAEssentials
import Combine

final class MainViewModel {
  private let dependencies: MainViewModel.Dependencies!
  private let actions: MainViewModel.Actions?
  private var bindings = Set<AnyCancellable>()
  private var findBeaconsSubscription: AnyCancellable?
  /// fetched art Wald items
  private var artWaldItems: [OSCAArtWald] = []
  
  // MARK: - OUTPUT published
  /// view model state
  @Published private(set) var state: MainViewModel.State = .loading
  /// found beacon
  @Published private(set) var artWaldBeacons: [OSCAArtWald] = []
  
  let imageDataCache = NSCache<NSString, NSData>()
  
  init(actions: MainViewModel.Actions,
       dependencies: MainViewModel.Dependencies) {
    self.actions = actions
    self.dependencies = dependencies
  }// end init
  
  deinit {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if !bindings.isEmpty {
      for sub in bindings {
        bindings.remove(sub)
        sub.cancel()
      }// end for sub in bindings
    }// end if
  }// end deinit
}// end final class MainViewModel

// MARK: - Dependencies
extension MainViewModel {
  struct Dependencies {
    let dataModule: OSCACulture
    let colorConfig: OSCAColorConfig
    let fontConfig: OSCAFontConfig
  }// end struct Dependencies
}// end extension final class MainViewModel

// MARK: - Error
extension MainViewModel {
  enum Error {
    case beaconScanning
    case artWaltFetch
  }// end enum Error
}// end extension MainViewModel
extension MainViewModel.Error: Swift.Error {}
extension MainViewModel.Error: Equatable {}

// MARK: - State
extension MainViewModel {
  enum State {
    case scanning
    case finishedScanning
    case loading
    case finishedLoading
    case error(MainViewModel.Error)
  }// end enum State
}// end extension final class MainViewModel
extension MainViewModel.State: Equatable {}

// MARK: - Actions
extension MainViewModel {
  struct Actions {
    let showDetails: (OSCAArtWald) -> Void
    let showWebView: (URL) -> Void
    let dismiss: () -> Void
    let openDeviceSettings: () -> Void
  }// end struct Actions
}// end extension final class MainViewModel

// MARK: - access data
extension MainViewModel {
  var dataModule: OSCACulture {
    dependencies.dataModule
  }// end var dataModule
  
  var colorConfig: OSCAColorConfig {
    dependencies.colorConfig
  }// end var colorConfig
  
  var fontConfig: OSCAFontConfig {
    dependencies.fontConfig
  }// end var fontConfig
  
  func fetchAllArtWald() -> Void {
    let publisher: OSCACulture.ArtWaldPublisher = dependencies
      .dataModule
      .fetchAllArtWald()
    if state != .loading {
      state = .loading
    }// end if
    var sub: AnyCancellable?
    sub = publisher
      .receive(on: RunLoop.main)
      .sink {[weak self] completion in
        guard let `self` = self,
              let sub = sub else { return }
        self.bindings.remove(sub)
        sub.cancel()
        switch completion {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          self.state = .error(.artWaltFetch)
        }// end switch case
      } receiveValue: { arts in
        self.artWaldItems = arts
        self.findBeacons()
      }// end receive closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end func fetchAllArtWald
  
  func findBeacons() -> Void {
    guard !artWaldItems.isEmpty else { return }
    let publisher: OSCACulture.ArtWaldBeaconsPublisher = dataModule
      .findBeacons()
    if state != .scanning {
      state = .scanning
    }// end if
    var sub: AnyCancellable?
    sub = publisher
      .receive(on: RunLoop.main)
      .dropFirst()
      .throttle(for: 5.0, scheduler: RunLoop.main, latest: true)
      .sink {[weak self] completion in
        guard let `self` = self,
              let sub = sub else { return }
        switch completion {
        case .finished:
          self.bindings.remove(sub)
          sub.cancel()
          self.state = .finishedScanning
        case .failure:
          self.state = .error(.beaconScanning)
        }// end switch case
      } receiveValue: { [weak self] beacons in
        guard let `self` = self,
              !self.artWaldItems.isEmpty else { return }
        self.artWaldBeacons = self.artWaldItems
          .filter { item in beacons.contains{ $0.minor == item.minor }}
          .map {
            var item = $0
            item.proximity = beacons.first(where: { $0.minor == item.minor })?.proximity ?? .unknown
            return item
          }
          .sorted(by: { $0.proximity.rawValue < $1.proximity.rawValue })
      }// end receive closure
    guard let sub = sub else { return }
    bindings.insert(sub)
    findBeaconsSubscription = sub
  }// end func fetchBeacon
}// end extension final class MainViewModel

// MARK: - INPUT: lifecycle
extension MainViewModel {
  func viewDidLoad() -> Void {
    fetchAllArtWald()
  }// end func viewDidLoad
  
  func viewWillAppear() -> Void {
    #warning("TODO: check conditions")
  }// end func viewWillAppear
  
  func viewDidLayoutSubviews() -> Void {
    #warning("TODO: viewDidLayoutSubviews")
  }// end func viewDidLayoutSubviews
  
  func viewDidDisappear() -> Void {
    #warning("TODO: viewDidDisappear")
  }// end func viewDidDisappear
}// end extension final class MainViewModel

// MARK: - INPUT: view events
extension MainViewModel {
  func openWeb(_ url: URL) -> Void {
    actions?.showWebView(url)
  }// end func openWeb with url
  
  func closeButtonTouch() -> Void {
    if let findBeaconsSubscription = findBeaconsSubscription {
      bindings.remove(findBeaconsSubscription)
      findBeaconsSubscription.cancel()
    }// end if
    actions?.dismiss()
  }// end func closeButtonTouch
  
  func openDeviceSettings() -> Void {
    
  }// end func openDeviceSettings
}// end extension inal class MainViewModel

// MARK: - OUTPUT
extension MainViewModel {
  var defaultEventLocation: OSCAGeoPoint {
    return OSCAGeoPoint(latitude: 51.184277, longitude: 7.042898)
  }// end var defaultEventLocation
}// end extension final class MainViewModel

// MARK: - OUTPUT: localized strings
extension MainViewModel {
  var screenTitle: String { return NSLocalizedString(
    "jobs_title",
    bundle: Bundle(for: Self.self),
    comment: "The screen title for press releases")}
  
  var alertTitleError: String { return NSLocalizedString(
    "alert_title_error",
    bundle: Bundle(for: Self.self),
    comment: "The alert title for an error")}
  
  var alertActionConfirm: String { return NSLocalizedString(
    "alert_title_confirm",
    bundle: Bundle(for: Self.self),
    comment: "The alert action title to confirm")}
  
  var mainDescriptionLabelText: String { return NSLocalizedString("main_description_label_text",
                                                                  bundle: Bundle(for: Self.self),
                                                                  comment: "The main description label text")}
}// end extension final class MainViewModel
