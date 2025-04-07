//
//  BeaconView.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 19.09.20.
//  Reviewed by Stephan Breidenbach on 24.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//
import UIKit
import OSCAEssentials

class BeaconView: UIView {
    @IBOutlet var openButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        openButton.layer.cornerRadius = openButton.frame.size.height / 2
        openButton.clipsToBounds = true

        containerView.layer.cornerRadius = 16.0
        containerView.clipsToBounds = true

        layer.cornerRadius = 16.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 10

        if #available(iOS 13.0, *) {
            containerView.backgroundColor = .systemBackground
        } else {
            containerView.backgroundColor = .white
        }
    }

    func setupView(title: String?, subtitle: String?, target: Any?, selector: Selector) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        openButton.addTarget(target, action: selector, for: .touchUpInside)
    }

    func setImage(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
      // Removed KF
//        imageView.kf.indicatorType = .activity
//        imageView.kf.setImage(with: url, placeholder: UIImage(), options: [.transition(.fade(0.3)), .cacheOriginalImage, .diskCacheExpiration(.days(7)), .memoryCacheExpiration(.days(1))])
    }
}
