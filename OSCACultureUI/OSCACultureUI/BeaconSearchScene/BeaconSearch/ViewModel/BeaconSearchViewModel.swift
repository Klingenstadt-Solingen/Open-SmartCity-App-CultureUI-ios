//
//  BeaconSearchViewModel.swift
//  CleanArchitectureMVVM
//
//  Created by Ömer Kurutay on 17.11.21.
//  Reviewed by Stephan Breidenbach on 24.09.22
//

import Foundation
import OSCACulture
import OSCAEssentials
import Combine

final class BeaconSearchViewModel {
  private let dependencies: BeaconSearchViewModel.Dependencies!
  private let actions: BeaconSearchViewModel.Actions?
  private var bindings = Set<AnyCancellable>()
  private var findBeaconsSubscription: AnyCancellable?
  private var getLocationStateSubscription: AnyCancellable?
  /// center location of beacon region
  private var beaconRegionCenter: OSCAGeoPoint?
  /// fetched art Wald items
  private var artWaldItems: [OSCAArtWald] = []
  /// location state
  @Published private var locationState: OSCALocationState = .initializing
  
  // MARK: - OUTPUT published
  @Published private(set) var beaconDistance: String = ""
  /// view model state
  @Published private(set) var state: BeaconSearchViewModel.State = .loading
  /// found beacon
  @Published private(set) var artWaldBeacons: [OSCAArtWald] = []
  
  let imageDataCache = NSCache<NSString, NSData>()
  
  init(actions: BeaconSearchViewModel.Actions,
       dependencies: BeaconSearchViewModel.Dependencies) {
    self.actions = actions
    self.dependencies = dependencies
  }// end init
  
  // MARK: - Private
  private func calculateDistance() -> Bool {
    return true
  }// end
  
  func bind(to locationState: OSCALocationState) -> Void {
    let locationStateValueHandler: (OSCALocationState) -> Void = { locationState in
      switch locationState {
      case .noPermission:
        if self.state != .noPermission { self.state = .noPermission }
      case let .outOfGeoRange(center):
        if self.state != .outOfGeoRange(center: center) {
          self.beaconRegionCenter = center
          self.state = .outOfGeoRange(center:center)
        }// end if
      case let .inGeoRange(center):
        if self.state != .inGeoRange(center: center) {
          self.beaconRegionCenter = center
          self.state = .inGeoRange(center:center)
        }// end if
      case .didRangeBeacon:
        if self.state == .scanning { self.state = .didRangeBeacon }
      case .initializing, .updatingLocation:
        return
      }// end switch case
    }// end locationStateValueHandler
    var sub: AnyCancellable?
    
    sub = $locationState
      .receive(on: RunLoop.main)
      .sink(receiveValue: locationStateValueHandler)
    guard let stateSub = sub else { return }
    bindings.insert(stateSub)
  }// end private func bind to location state
  
  deinit {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    cancelFindBeacons()
    cancelGetLocationState()
    if !bindings.isEmpty {
      for sub in bindings {
        bindings.remove(sub)
        sub.cancel()
      }// end for sub in bindings
    }// end if
  }// end deinit
}// end final class BeaconSearchViewModel


// MARK: - Dependencies
extension BeaconSearchViewModel {
  struct Dependencies {
    let dataModule: OSCACulture
    let colorConfig: OSCAColorConfig
    let fontConfig: OSCAFontConfig
  }// end struct Dependencies
}// end extension final class BeaconSearchViewModel

// MARK: - Error
extension BeaconSearchViewModel {
  enum Error {
    case beaconScanning
    case artWaltFetch
  }// end enum Error
}// end extension BeaconSearchViewModel
extension BeaconSearchViewModel.Error: Swift.Error {}
extension BeaconSearchViewModel.Error: Equatable {}

// MARK: - State
extension BeaconSearchViewModel {
  enum State {
    case scanning
    case didRangeBeacon
    case finishedScanning
    case loading
    case finishedLoading
    case noPermission
    /* case noBluetooth */
    case outOfGeoRange(center: OSCAGeoPoint)
    case inGeoRange(center: OSCAGeoPoint)
    case error(BeaconSearchViewModel.Error)
  }// end enum State
}// end extension final class BeaconSearchViewModel
extension BeaconSearchViewModel.State: Equatable {}

// MARK: - Actions
extension BeaconSearchViewModel {
  struct Actions {
    let showDetails: (OSCAArtWald) -> Void
    let showWebView: (URL) -> Void
    let dismiss: () -> Void
    let openDeviceSettings: () -> Void
  }// end struct Actions
}// end extension final class BeaconSearchViewModel

// MARK: - access data
extension BeaconSearchViewModel {
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
      } receiveValue: { [weak self] arts in
        guard let `self` = self else { return }
        self.artWaldItems = arts
      }// end receive closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end func fetchAllArtWald
  
  func getLocationState() -> Void {
    guard !artWaldItems.isEmpty else { return }
    bind(to: self.locationState)
    let publisher: OSCALocationStatePublisher = dataModule
      .getLocationState(for: artWaldItems)
    var sub: AnyCancellable?
    sub = publisher
      .receive(on: RunLoop.main)
      .sink { [weak self] completion in
        guard let `self` = self,
              let sub = sub else { return }
        self.bindings.remove(sub)
        sub.cancel()
        switch completion {
        case .finished:
          self.state = .finishedScanning
        case let .failure(never):
          print(never.localizedDescription)
        }
      } receiveValue: {[weak self] in
        guard let `self` = self else { return }
        self.locationState = $0
      }// end sink
    guard let sub = sub else { return }
    bindings.insert(sub)
    getLocationStateSubscription = sub
  }// end getLocationState
  
  func cancelGetLocationState() -> Void {
    guard let sub = getLocationStateSubscription else { return }
    bindings.remove(sub)
    sub.cancel()
    getLocationStateSubscription = nil
  }// end func cancelGetLocationState
  
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
      /*.throttle(for: 2.0, scheduler: RunLoop.main, latest: true)*/
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
    
  }// end func fetchBeacons
  
  func cancelFindBeacons() -> Void {
    guard let sub = findBeaconsSubscription else { return }
    bindings.remove(sub)
    sub.cancel()
    findBeaconsSubscription = nil
  }// end func cancelFindBeacons
}// end extension final class BeaconSearchViewModel

// MARK: - INPUT: lifecycle
extension BeaconSearchViewModel {
  func viewDidLoad() -> Void {
    fetchAllArtWald()
  }// end func viewDidLoad
  
  func viewWillAppear() -> Void {}// end func viewWillAppear
  
  func viewDidLayoutSubviews() -> Void {}// end func viewDidLayoutSubviews
  
  func viewDidDisappear() -> Void {}// end func viewDidDisappear
}// end extension final class BeaconSearchViewModel

// MARK: - INPUT: view events
extension BeaconSearchViewModel {
  func didOpenDeviceSettings() -> Void {
    if let getLocationStateSubscription = getLocationStateSubscription {
      bindings.remove(getLocationStateSubscription)
      getLocationStateSubscription.cancel()
      getLocationState()
    }
  }// end func didOpenDeviceSettings
  
  func cellForItem(at index: Int) -> OSCAArtWald? {
    guard self.artWaldBeacons.count > index else { return nil }
    return self.artWaldBeacons[index]
  }// end func cellForItem at index
  
  func numberOfItemsInSection(_ section: Int) -> Int {
    return artWaldBeacons.count
  }// end func numberOfItemsInSection
  
  func didSelectItem(at index: Int) -> Void {
    guard self.artWaldBeacons.count > index else { return }
    actions?.showDetails(artWaldBeacons[index])
  }// end func didSelectItem at index
  
  func openWeb() -> Void {
    guard let url = URL(string: webLink) else { return }
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
    actions?.openDeviceSettings()
  }// end func openDeviceSettings
}// end extension inal class BeaconSearchViewModel

// MARK: - OUTPUT
extension BeaconSearchViewModel {
  var defaultEventLocation: OSCAGeoPoint {
    return OSCAGeoPoint(latitude: 51.184277, longitude: 7.042898)
  }// end var defaultEventLocation
  
  var eventLocation: OSCAGeoPoint {
    if let center = beaconRegionCenter {
      return center
    } else {
      return defaultEventLocation
    }// end if
  }//end eventLocation
  
  var descriptionLinks: [String] { return ["quartier-wald.de"] }
  var webLink: String { return "https://quartier-wald.de" }
}// end extension final class BeaconSearchViewModel

// MARK: - OUTPUT: localized strings
extension BeaconSearchViewModel {
  var description: String { return NSLocalizedString("beacon_description_label_text",
                                                     bundle: OSCACultureUI.bundle,
                                                     comment: "The beacon description label text")}
  var header: String { return NSLocalizedString(
    "beacon_header_text",
    bundle: OSCACultureUI.bundle,
    comment: "header text")}
  
  var alertTitleError: String { return NSLocalizedString(
    "alert_title_error",
    bundle: OSCACultureUI.bundle,
    comment: "The alert title for an error")}
  
  var alertActionConfirm: String { return NSLocalizedString(
    "alert_title_confirm",
    bundle: OSCACultureUI.bundle,
    comment: "The alert action title to confirm")}
  
  /// right bar button item title close
  var rightBarButtonItemTitleClose: String { return NSLocalizedString(
    "right_bar_button_item_title_close",
    bundle: OSCACultureUI.bundle,
    comment: "The right bar button item title close")}
  
  /// distance label text
  var distanceLabelText: String {return NSLocalizedString(
    "distance_label_text",
    bundle: OSCACultureUI.bundle,
    comment: "The distance label text")}
  
  /// loading label text
  var loadingLabelText: String {return NSLocalizedString(
    "loading_label_text",
    bundle: OSCACultureUI.bundle,
    comment: "The loading label text")}
}// end extension final class BeaconSearchViewModel
