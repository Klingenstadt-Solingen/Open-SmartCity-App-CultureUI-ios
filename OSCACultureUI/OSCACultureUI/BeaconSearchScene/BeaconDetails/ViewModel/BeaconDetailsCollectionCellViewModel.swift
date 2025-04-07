//
//  BeaconDetailsCollectionCellViewModel.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 28.09.22.
//

import Foundation
import Combine
import OSCACulture
import OSCAEssentials

final class BeaconDetailsCollectionCellViewModel {
  private let dataModule: OSCACulture
  private let cellRow: Int
  private var bindings = Set<AnyCancellable>()
  let imageDataCache: NSCache<NSString, NSData>
  var imageGalleryURLThumb: URL
  
  @Published private(set) var galleryThumbImageData: Data? = nil
  
  init(imageCache: NSCache<NSString, NSData>,
       imageGalleryURLThumb: URL,
       dataModule: OSCACulture,
       at row: Int) {
    imageDataCache = imageCache
    self.imageGalleryURLThumb = imageGalleryURLThumb
    self.dataModule = dataModule
    self.cellRow = row
    setupBindings()
  }// end init
  
  func setupBindings() -> Void {
    
  }// end func setupBindings
}// end final class BeaconDetailsCollectionCellViewModel

extension BeaconDetailsCollectionCellViewModel {
  var imageDataFromCache: Data? {
    let urlString = imageGalleryURLThumb.absoluteString
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
}// end extension final class BeaconDetailsCollectionCellViewModel

extension BeaconDetailsCollectionCellViewModel {
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
        self.galleryThumbImageData = imageThumbData
      }// end receive closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end private func fetchImage from URL
}// end extension final class BeaconDetailsCollectionCellViewModel

extension BeaconDetailsCollectionCellViewModel {
  func didSetViewModel() {
    if let imageDataFromCache = self.imageDataFromCache {
      galleryThumbImageData = imageDataFromCache
    } else {
      fetchImage(from: imageGalleryURLThumb)
    }// end if
  }// end func didSetViewModel
}// end extension final class BeaconDetailsCollectionCellViewModel
