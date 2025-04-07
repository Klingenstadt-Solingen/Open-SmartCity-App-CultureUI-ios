//
//  BeaconSearchCollectionViewCell.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 15.10.20.
//  Reviewed by Stephan Breidenbach on 24.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//

import UIKit
import OSCACulture

final class BeaconSearchCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: BeaconSearchCollectionViewCell.self)
  
  @IBOutlet private var distanceLabel: UILabel!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtitleLabel: UILabel!
  @IBOutlet private var containerView: UIView!
  
  private var artWaldBeacon: OSCAArtWald! {
    didSet {
      setupView()
    }// end didSet
  }// end private var viewModel
  
  private func setupView() -> Void {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.2
    layer.shadowOffset = .init(width: 0, height: 4)
    layer.shadowRadius = 8
    
    containerView.layer.cornerRadius = 8
    containerView.layer.borderWidth = 1.0
    containerView.layer.borderColor = UIColor.clear.cgColor
    containerView.layer.masksToBounds = true
    containerView.backgroundColor = .white
  }// end private func setupView
  
  func fill(with artWaldBeacon: OSCAArtWald, _ distance: String) -> Void {
    self.artWaldBeacon = artWaldBeacon
    titleLabel.text = artWaldBeacon.hotspotTitle
    #if DEBUG
    if let minor = artWaldBeacon.minor { subtitleLabel.text = "minor: \(minor)"}
    distanceLabel.text = "\(artWaldBeacon.proximity)"
    #else
    subtitleLabel.text = "Hotspot"
    distanceLabel.text = distance
    #endif
  }// end func fill with artWaldBeacon
}// end BeaconSearchCollectionViewCell
