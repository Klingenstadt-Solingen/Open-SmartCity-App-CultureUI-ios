//
//  BeaconDetailsArtistTableViewCell.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 19.09.20.
//  Reviewed by Stephan Breidenbach on 27.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//

import Combine
import UIKit

final class BeaconDetailsArtistTableViewCell: UITableViewCell {
  static let reuseIdentifier = "BeaconDetailsArtistTableViewCell"
  private var bindings = Set<AnyCancellable>()
  
  var viewModel: BeaconDetailsTableCellViewModel! {
    didSet {
      setupView()
      setupBindings()
      viewModel.didSetViewModel()
    }// end didSet
  }// end var viewModel
  
  private func setupView() -> Void {
    guard let artistImageView = artistImageView,
          let nameLabel = nameLabel,
          let descriptionLabel = descriptionLabel
    else { return }
    if let imageDataFromCache = viewModel.imageDataFromCache {
      artistImageView.image = UIImage(data: imageDataFromCache)
    } else {
      artistImageView.image = UIImage.placeholder
    }// end if
    nameLabel.text = viewModel.artistName
    descriptionLabel.text = viewModel.artisanCrafts
  }// end private func setupView
  
  @IBOutlet private var artistImageView: UIImageView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var descriptionLabel: UILabel!
  
  @IBAction func openWebsiteTouch(_: UIButton) {
    viewModel.openWebsite()
  }// end func openWebsiteTouch
  
  private func setupBindings() {
    let publisher = viewModel
      .$imageData
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
              let imageData = imageData,
              let artistImageView = self.artistImageView else { return }
        artistImageView.image = UIImage(data: imageData)
      }// end receiveValue closure
    guard let sub = sub else { return }
    bindings.insert(sub)
  }// end private func setupBindings()
}// end final class BeaconDetailsArtistTableViewCell
