//
//  BeaconDetailsTableCellViewModel.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 28.09.22.
//

import Foundation
import Combine
import OSCACulture
import OSCAEssentials

final class BeaconDetailsTableCellViewModel {
  private let dataModule: OSCACulture
  private let cellRow: Int
  private let actions: BeaconDetailsTableCellViewModel.Actions!
  private var bindings = Set<AnyCancellable>()
  let imageDataCache: NSCache<NSString, NSData>
  var artist: OSCAArtWald.Artist? = nil
  
  @Published private(set) var imageData: Data? = nil
  
  init(imageCache: NSCache<NSString, NSData>,
       artist: OSCAArtWald.Artist,
       dataModule: OSCACulture,
       at row: Int,
       actions: BeaconDetailsTableCellViewModel.Actions) {
    imageDataCache = imageCache
    self.artist = artist
    self.dataModule = dataModule
    self.cellRow = row
    self.actions = actions
    setupBindings()
  }// end init
  
  func setupBindings() -> Void {
    
  }// end func setupBindings
  
  func openWebsite() -> Void {
    guard let artistHomepage = artistHomepage else { return }
    actions.showWebsite(artistHomepage)
  }// end func openWebsite with url
}// end final class BeaconDetailsTableCellViewModel

extension BeaconDetailsTableCellViewModel {
  struct Actions {
    let showWebsite: (URL) -> Void
  }// end struct Actions
}// end extension final class BeaconDetailsTableCellViewModel

extension BeaconDetailsTableCellViewModel {
  var imageDataFromCache: Data? {
    guard let artist = artist,
          let imageURL = artist.thumbImageURL else { return nil }
    let urlString = imageURL.absoluteString
    let imageData = imageDataCache.object(forKey: NSString(string: urlString))
    return imageData as Data?
  }// end var imageDataFromCache
  
  private func put(imageData: Data, for url: URL) -> Void {
    let imageNSData = imageData as NSData
    let urlString = url.absoluteString
    let urlNSString = urlString as NSString
    imageDataCache.setObject(imageNSData,
                             forKey: urlNSString)
  }// end private func put image data for url
}// end extension final class BeaconDetailsTableCellViewModel

extension BeaconDetailsTableCellViewModel {
  private func fetchImage(from url: URL) {
    let publisher = dataModule
      .fetchImageData(from: url)
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
#if DEBUG
          print("\(String(describing: self)): \(#function)")
#endif
        case .failure:
#if DEBUG
          print("\(String(describing: self)): \(#function)")
#endif
        }// end switch case
      } receiveValue: { [weak self] imageThumbData in
        guard let `self` = self else { return }
        // put image data to image cache
        self.put(imageData: imageThumbData, for: url)
        // set image data to publisher
        self.imageData = imageThumbData
      }// end receive closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end private func fetchImage from URL
}// end extension final class BeaconDetailsTableCellViewModel

extension BeaconDetailsTableCellViewModel {
  func didSetViewModel() -> Void {
    guard let artist = artist,
          let imageURL = artist.thumbImageURL else { return }
    if let imageDataFromCache = self.imageDataFromCache {
      imageData = imageDataFromCache
    } else {
      fetchImage(from: imageURL)
    }// end if
  }// end func didSetViewModel
}// end extension final class BeaconDetailsTableCellViewModel

extension BeaconDetailsTableCellViewModel  {
  var artistName: String {
    guard let artist = artist,
          let name = artist.name
    else { return "" }
    return name
  }// end var artistName
  
  var artisanCrafts: String {
    guard let artist = artist,
          let artisanCrafts = artist.artisanCraft
    else { return "" }
    return artisanCrafts
  }// end var artisanCrafts
  
  var artistHomepage: URL? {
    guard let artist = artist,
          let homepageURL = artist.homepageURL
    else { return nil }
    return homepageURL
  }// end var artistHomepage
}// end extension final class BeaconDetailsTableCellViewModel
