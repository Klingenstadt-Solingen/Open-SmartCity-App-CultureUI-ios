//
//  BeaconDetailsImageGalleryCollectionViewCell.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 19.09.20.
//  Reviewed by Stephan Breidenbach on 27.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//

import Combine
import UIKit

final class BeaconDetailsImageGalleryCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: BeaconDetailsImageGalleryCollectionViewCell.self)
  private var bindings = Set<AnyCancellable>()
  
  var viewModel: BeaconDetailsCollectionCellViewModel! {
    didSet {
      setupView()
      setupBindings()
      viewModel.didSetViewModel()
    }// end didSet
  }// end var viewModel
  
  private func setupView() -> Void {
    if let imageDataFromCache = viewModel.imageDataFromCache {
      imageView.image = UIImage(data: imageDataFromCache)
    } else {
      imageView.image = UIImage.placeholder
    }// end if
  }// end private func setupView
  
  private func setupBindings() {
    let publisher = viewModel
      .$galleryThumbImageData
    var sub: AnyCancellable?
    sub = publisher
      .receive(on: RunLoop.main)
      .dropFirst()
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
      } receiveValue: { [weak self] imageData in
        guard let `self` = self,
              let imageData = imageData else { return }
        self.imageView.image = UIImage(data: imageData)
      }// end receiveValue closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end private func setupBindings()
  
  @IBOutlet private var imageView: UIImageView!
}// end final class BeaconDetailsImageGalleryCollectionViewCell
