//
//  BeaconImageDetailsViewModel.swift
//  CleanArchitectureMVVM
//
//  Created by Ömer Kurutay on 16.11.21.
//  Reviewed by Stephan Breidenbach on 24.09.22
//

import Foundation
import Combine
import OSCAEssentials
import OSCACulture

final class BeaconImageDetailsViewModel {
  let urls: [URL]
  let page: Int?
  let dependencies: BeaconImageDetailsViewModel.Dependencies
  private let actions: BeaconImageDetailsViewModel.Actions
  private var bindings: Set<AnyCancellable> = Set<AnyCancellable>()
  /// image cache
  private let _imageDataCache = NSCache<NSString, NSData>()
  /// image cache setter  image data for key url
  func set(data: Foundation.Data, for key: URL) -> Void {
    let urlString = key.absoluteString
    guard !urlString.isEmpty else { return }
    self._imageDataCache.setObject(data as NSData,
                                   forKey: urlString as NSString)
  }// end func set
  /// image cache getter image data for key url
  func get(for key: URL) -> Foundation.Data? { self._imageDataCache.object(forKey: key.absoluteString as NSString) as? Data }
  
  // MARK: - OUTPUT
  @Published private(set) var state: BeaconImageDetailsViewModel.State = .loading
  
  let closeImage: String = "times-light-svg"
  
  init(urls: [URL],
       page: Int? = nil,
       actions: BeaconImageDetailsViewModel.Actions,
       dependencies: BeaconImageDetailsViewModel.Dependencies) {
    self.urls = urls
    self.page = page
    self.actions = actions
    self.dependencies = dependencies
  }// end init
}// end class BeaconImageDetailsViewModel

// MARK: - Dependencies
extension BeaconImageDetailsViewModel {
  struct Dependencies {
    let dataModule: OSCACulture
    let colorConfig: OSCAColorConfig
    let fontConfig: OSCAFontConfig
  }// end struct Dependencies
}// end extension final class BeaconImageDetailsViewModel

// MARK: - Section
extension BeaconImageDetailsViewModel {
  enum Section {
    case imageURLs
  }// end enum Section
}// end extension final class BeaconImageDetailsViewModel

// MARK: - Error
extension BeaconImageDetailsViewModel {
  enum Error {
    case imageFetch
  }// end enum Error
}// end extension final class BeaconImageDetailsViewModel
extension BeaconImageDetailsViewModel.Error: Swift.Error {}
extension BeaconImageDetailsViewModel.Error: Equatable {}

// MARK: - State
extension BeaconImageDetailsViewModel {
  enum State {
    case loading
    case finishedLoading
    case error(BeaconImageDetailsViewModel.Error)
  }// end enum State
}// end extension final class BeaconImageDetailsViewModel

extension BeaconImageDetailsViewModel.State: Equatable {}

// MARK: - Actions
extension BeaconImageDetailsViewModel {
  struct Actions{
    let dismissImageDetail: () -> Void
  }// end struct Actions
}// end extension final class BeaconImageDetailsViewModel

// MARK: - access data
extension BeaconImageDetailsViewModel {
  var dataModule: OSCACulture {
    dependencies.dataModule
  }// end var dataModule
  
  var colorConfig: OSCAColorConfig {
    dependencies.colorConfig
  }// end var colorConfig
  
  var fontConfig: OSCAFontConfig {
    dependencies.fontConfig
  }// end var fontConfig
  
  func fetchGalleryImages() -> Void {
    if self.state != .loading { self.state = .loading }
    var count = urls.count
    for i in 0 ..< urls.count {
      let url = urls[i]
      
      let publisher = dependencies
        .dataModule
        .fetchImageData(from: url)
      var sub: AnyCancellable?
      sub = publisher
        .receive(on: RunLoop.main)
        .sink {[weak self] completion in
          guard let `self` = self,
                let sub = sub else { return }
          self.bindings.remove(sub)
          sub.cancel()
          count -= 1
          // is it the last url in urls?
          if count == 0 {
            self.state = .finishedLoading
          }
        } receiveValue: { [weak self] imageData in
          guard let `self` = self else { return }
          set(data: imageData,
              for: url)
        }// end receive closure
      guard let sub = sub else { return }
      bindings.insert(sub)
    }// for i
  }// end func fetchGalleryImages
}// end extension final class BeaconImageDetailsViewModel

// MARK: - INPUT. View event methods
extension BeaconImageDetailsViewModel {
  func viewDidLoad() {
    fetchGalleryImages()
  }// end func viewDidLoad
  
  func viewDidLayoutSubviews() {}// end func viewDidLayoutSubviews
}// end extension final class BeaconImageDetailsViewModel

// MARK: - INPUT: view events
extension BeaconImageDetailsViewModel {
  
  func dismissImageDetail() -> Void {
    actions.dismissImageDetail()
  }// end func showTitleImage
}// end extension final class BeaconImageDetailsViewModel
