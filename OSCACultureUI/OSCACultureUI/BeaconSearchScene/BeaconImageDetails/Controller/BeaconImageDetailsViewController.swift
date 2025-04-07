//
//  BeaconImageDetailsViewController.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 20.09.20.
//  Reviewed by Stephan Breidenbach on 24.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//

import UIKit
import OSCAEssentials
import OSCACulture
import Combine
//import Kingfisher

final class BeaconImageDetailsViewController: UIViewController {
  /// controller's activity indicator
  public lazy var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView.init(style: .large,
                                                                                            color: .darkGray)
  /// controller's bindings
  private var bindings = Set<AnyCancellable>()
  
  @IBOutlet private var closeButton: UIButton!
  @IBOutlet var containerView: UIView!
  @IBOutlet var pager: UIPageControl!
  
  var viewModel: BeaconImageDetailsViewModel!
  
  var page: Int?
  private var carousel: UIScrollView!
  
  override func viewDidLoad() -> Void {
    super.viewDidLoad()
    setupViews()
    bind(to: self.viewModel)
    self.viewModel.viewDidLoad()
  }// end override func viewDidLoad
  
  private func setupViews() -> Void {
    setupActivityIndicator()
    setupCloseButton()
    setupCarousel()
  }// end private func setupViews
  
  private func bind(to viewModel: BeaconImageDetailsViewModel) -> Void {
    let viewStateLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.showActivityIndicator()
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.hideActivityIndicator()
      self.fillImageCarousel()
    }// end let viewStateFinishedLoading
    
    let viewStateError: (BeaconImageDetailsViewModel.Error) -> Void = {[weak self] error in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      self.hideActivityIndicator()
      switch error {
      case .imageFetch:
#if DEBUG
        print("\(String(describing: self)): error imageFetch!")
#endif
      }// end switch case
    }// end let viewStateError
    
    let stateValueHandler: (BeaconImageDetailsViewModel.State) -> Void = {[weak self] viewModelState in
      guard self != nil else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      switch  viewModelState {
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case let .error(viewModelError):
        viewStateError(viewModelError)
      }// end switch case
    }// end let stateValueHandler
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }// end private func bind to view model
  
  override func viewDidLayoutSubviews() -> Void {
    super.viewDidLayoutSubviews()
    viewModel.viewDidLayoutSubviews()
  }// end override func viewDidLayoutSubviews
  
  private func slideTo(page: Int = 0, animated: Bool) -> Void {
    let offset = page == 0 ? 0 : (CGFloat(page) * containerView.bounds.width)
    let position = CGRect(x: offset, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
    carousel.scrollRectToVisible(position, animated: animated)
    calculatePage(for: carousel)
  }// end private func slideTo page
  
  private func setupCarousel() -> Void {
    carousel = UIScrollView(frame: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height))
    carousel.showsHorizontalScrollIndicator = false
    carousel.isPagingEnabled = true
    carousel.bounces = false
    carousel.delegate = self
  }// end private func setupCarousel
  
  private func setupCloseButton() -> Void {
    let image = UIImage(named: viewModel.closeImage,
                        in: OSCACultureUI.bundle,
                        with: .none)
    closeButton.setImage(image, for: .normal)
    let tap = UITapGestureRecognizer(
      target: self,
      action: #selector(closeButtonTouch))
    view.addGestureRecognizer(tap)
  }// end private funcn setupCloseButton
  
  private func fillImageCarousel() -> Void {
    let urls = viewModel.urls
    guard !urls.isEmpty else { return }
    for i in 0 ..< urls.count {
      let url = urls[i]
      let offset = i == 0 ? 0 : (CGFloat(i) * containerView.bounds.width)
      let imgView = UIImageView(frame: CGRect(x: offset, y: 0, width: containerView.bounds.width, height: containerView.bounds.height))
      imgView.clipsToBounds = true
      imgView.contentMode = .scaleAspectFill
      if let imageData = self.viewModel.get(for: url){
        imgView.image = UIImage(data: imageData)
      }// end if
      carousel.addSubview(imgView)
    }// end for i
    carousel.contentSize = CGSize(width: CGFloat(urls.count) * containerView.bounds.width, height: containerView.bounds.height)
    containerView.addSubview(carousel)
    pager.numberOfPages = urls.count
  }// end private func fillImageCarousel
  
  private func calculatePage(for scrollView: UIScrollView) -> Void {
    let x = scrollView.contentOffset.x
    let w = scrollView.bounds.size.width
    pager.currentPage = Int(ceil(x / w))
  }// end private func calculate page
  
  @IBAction func closeButtonTouch(_: UIButton) {
    viewModel.dismissImageDetail()
  }// end func closeButtonTouch
  
  @IBAction func pageSelected(_ sender: UIPageControl) {
    let page = sender.currentPage
    slideTo(page: page, animated: true)
  }// end func pageSelected
}// end final class BeaconImageDetailsViewController

extension BeaconImageDetailsViewController: ActivityIndicatable {
  /// configure activity indicator view
  /// * add activity indicator subview
  /// * define layout constraints
  func setupActivityIndicator() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      self.activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      self.activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      self.activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    ])
  }// end func setupAcitivityIndicator
}// end extension final class BeaconImageDetailsViewController

extension BeaconImageDetailsViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> Void {
    calculatePage(for: scrollView)
  }// end func scrollViewDidEndDecelerating
}// end extension final class BeaconImageDetailsViewController

// MARK: - instantiate view controller
extension BeaconImageDetailsViewController: StoryboardInstantiable {
  /// function call: var vc = BeaconImageDetailsViewController.create(viewModel)
  static func create(with viewModel: BeaconImageDetailsViewModel) -> BeaconImageDetailsViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCACultureUI.bundle
    let vc: BeaconImageDetailsViewController = BeaconImageDetailsViewController.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }// end static func create
}// end extension final class BeaconImageDetailsViewController

