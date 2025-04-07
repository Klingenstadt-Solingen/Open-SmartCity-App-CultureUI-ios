//
//  BeaconDetailsViewModel.swift
//  CleanArchitectureMVVM
//
//  Created by Ömer Kurutay on 16.11.21.
//  Reviewed by Stephan Breidenbach on 27.09.22
//

import Foundation
import Combine
import OSCAEssentials
import OSCACulture

final class BeaconDetailsViewModel {
  let artWaldItem: OSCAArtWald?
  let dependencies: BeaconDetailsViewModel.Dependencies
  private let actions: BeaconDetailsViewModel.Actions
  private var bindings: Set<AnyCancellable> = Set<AnyCancellable>()
  
  // MARK: - OUTPUT
  @Published private(set) var state: BeaconDetailsViewModel.State = .loading
  @Published private(set) var titleImageThumbData: Foundation.Data? = nil
  
  let imageDataCache = NSCache<NSString, NSData>()
  
  init(artWaldBeacon: OSCAArtWald,
       actions: BeaconDetailsViewModel.Actions,
       dependencies: BeaconDetailsViewModel.Dependencies) {
    self.artWaldItem = artWaldBeacon
    self.actions = actions
    self.dependencies = dependencies
  }// end init
} // end final class BeaconDetailsViewModel

// MARK: - Dependencies
extension BeaconDetailsViewModel {
  struct Dependencies {
    let dataModule: OSCACulture
    let colorConfig: OSCAColorConfig
    let fontConfig: OSCAFontConfig
  }// end struct Dependencies
}// end extension final class BeaconDetailsViewModel

// MARK: - Section
extension BeaconDetailsViewModel {
  enum Section {
    case galleryImageThumbURLs
  }// end enum Section
  
  enum TableSection {
    case artists
  }// end enum TableSection
}// end extension final class BeaconDetailsViewModel

// MARK: - Error
extension BeaconDetailsViewModel {
  enum Error {
    case imageFetch
  }// end enum Error
}// end extension final class BeaconDetailsViewModel
extension BeaconDetailsViewModel.Error: Swift.Error {}
extension BeaconDetailsViewModel.Error: Equatable {}

// MARK: - State
extension BeaconDetailsViewModel {
  enum State {
    case loading
    case finishedLoading
    case error(BeaconDetailsViewModel.Error)
  }// end enum State
}// end extension final class BeaconDetailsViewModel

// MARK: - Actions
extension BeaconDetailsViewModel {
  struct Actions{
    let showWebsite: (_ url: URL) -> Void
    let showImageGallery: (_ urls: [URL]) -> Void
    let showTitleImage: (_ url: URL) -> Void
    let dismissDetail: () -> Void
  }// end struct Actions
}// end extension final class BeaconDetailsViewModel

// MARK: - access data
extension BeaconDetailsViewModel {
  var dataModule: OSCACulture {
    dependencies.dataModule
  }// end var dataModule
  
  var colorConfig: OSCAColorConfig {
    dependencies.colorConfig
  }// end var colorConfig
  
  var fontConfig: OSCAFontConfig {
    dependencies.fontConfig
  }// end var fontConfig
  
  func fetchTitleImageThumb() -> Void {
    guard let artWaldItem = self.artWaldItem,
          let titleImageURLThumb = artWaldItem.titleImageURLThumb
    else { return }
    let publisher: OSCACulture.ImageDataPublisher = dependencies
      .dataModule
      .fetchImageData(from: titleImageURLThumb)
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
          self.state = .error(.imageFetch)
        }// end switch case
      } receiveValue: { [weak self] titleImageURLThumb in
        guard let `self` = self else { return }
        self.titleImageThumbData = titleImageURLThumb
      }// end receive closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end func fetchTitleImageThumb
}// end extension final class BeaconDetailsViewModel

// MARK: - INPUT: lifecycle
extension BeaconDetailsViewModel {
  func viewDidLoad() -> Void {
    fetchTitleImageThumb()
  }// end func viewDidLoad
  
  func viewDidLayoutSubviews() -> Void {}
}// end extension final class BeaconDetailsViewModel

// MARK: - INPUT: view events
extension BeaconDetailsViewModel {
  func showWebsite(from url: URL) -> Void {
    actions.showWebsite(url)
  }// end func showWebsite
  
  func updateSections() -> [URL] {
    guard let artWaldItem = artWaldItem else { return [] }
    return artWaldItem.imageGalleryURLThumbs
  }// end func updateSections
  
  func updateTableSections() -> [OSCAArtWald.Artist] {
    return artists
  }// end func updateTableSections
  
  func showImageGallery() -> Void {
    guard let artWaldItem = artWaldItem else { return }
    let imageGalleryURLs = artWaldItem.imageGalleryURLs
    actions.showImageGallery(imageGalleryURLs)
  }// end func showImageGallery
  
  func showTitleImage() -> Void {
    guard let artWaldItem = artWaldItem,
          let titleImageURL = artWaldItem.titleImageURL else { return }
    actions.showTitleImage(titleImageURL)
  }// end func showTitleImage
}// end extension final class BeaconDetailsViewModel

// MARK: - OUTPUT
extension BeaconDetailsViewModel {
  var artists: [OSCAArtWald.Artist] {
    guard let artWaldItem = artWaldItem,
          let artists = artWaldItem.artistList else { return [] }
    return artists
  }// end var artists
  
  var thumbPath: String { return "https://geoportal.solingen.de/buergerservice1/ressourcen/kunstinwald/thumbs/" }// end var thumbPath
  
  var imageExtension: String { return ".jpg" }// end var imageExtension
  
  var topTitle: String { return "Hotspot" }// end var topTitle
  
  var htmlString: String { return "\(css)\(artWaldItem?.summary ?? "")<br><br>\(artWaldItem?.artistTitle ?? "")<br><br>\(forMore)" }// end htmlString
  
  private var css: String { return "<style> body {font-stretch: normal; font-size: 15px; line-height: normal; font-family: 'Helvetica Neue'} </style>" }// end private var css
  
  private var forMore: String { return "Schau dich um in WALD und finde mehr Kunstwerke – oder klicke dazu <a href='https://www.quartierwald.de/hotspots/'>hier</a>." }// end private var forMore
  
}// end extension final class BeaconDetailsViewModel

// MARK: - OUTPUT: localized strings
extension BeaconDetailsViewModel {}// end extension final class BeaconDetailsViewModel
