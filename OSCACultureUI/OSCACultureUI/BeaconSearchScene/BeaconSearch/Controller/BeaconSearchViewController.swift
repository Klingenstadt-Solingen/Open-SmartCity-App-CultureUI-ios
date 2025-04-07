//
//  BeaconSearchViewController.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 15.10.20.
//  Reviewed by Stephan Breidenbach on 24.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//

import UIKit
import OSCAEssentials
import Combine

final class BeaconSearchViewController: UIViewController {
  @IBOutlet var rightBarButton: UIBarButtonItem!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var tableContentView: UIView!
  @IBOutlet var noPermissionView: UIView!
  @IBOutlet var distanceView: UIView!
  @IBOutlet var loadingView: UIView!
  @IBOutlet var routeButton: UIView!
  @IBOutlet var headerLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var loadingLabel: UILabel!
  
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var viewModel: BeaconSearchViewModel!
  
  private var bindings = Set<AnyCancellable>()
  
  private func bind(to viewModel: BeaconSearchViewModel) -> Void {
    let viewStateLoading: () -> Void = { [weak self] in
      guard let `self` = self else { return }
      self.showActivityIndicator()
      self.tableContentView.isHidden = true
      self.loadingView.isHidden = true
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.hideActivityIndicator()
      self.tableContentView.isHidden = true
      self.loadingView.isHidden = true
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
      self.viewModel.getLocationState()
    }// end let viewStateFinishedLoading
    
    /*
     let viewStateNoBluetooth: () -> Void = {[weak self] in
     guard let `self` = self else { return }
     self.hideActivityIndicator()
      
    }//
    
     */
    
    let viewStateNoPermission: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.tableContentView.isHidden = true
      self.loadingView.isHidden = true
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = false
    }// end let viewStateNoPermission
    
    let viewStateOutOfGeoRange: (OSCAGeoPoint) -> Void = {[weak self] _ in
      guard let `self` = self else { return }
      self.tableContentView.isHidden = true
      self.loadingView.isHidden = true
      self.distanceView.isHidden = false
      self.noPermissionView.isHidden = true
      viewModel.cancelFindBeacons()
    }// end let viewStateOutOfGeoRange
    
    let viewStateInGeoRange: (OSCAGeoPoint) -> Void = {[weak self] _ in
      guard let `self` = self else { return }
      self.tableContentView.isHidden = false
      self.loadingView.isHidden = false
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
      viewModel.findBeacons()
    }// end let viewStateInGeoRange
    
    let viewStateScanning: () -> Void = { [weak self] in
      guard let `self` = self else { return }
      self.tableContentView.isHidden = false
      self.loadingView.isHidden = false
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
    }// end let viewStateLoading
    
    let viewStateDidRangeBeacon: () -> Void = { [weak self] in
      guard let `self` = self else { return }
      self.tableContentView.isHidden = false
      self.loadingView.isHidden = true
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
    }// end let viewStateDidRangeBeacon
    
    let viewStateFinishedScanning: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.tableContentView.isHidden = true
      self.loadingView.isHidden = true
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
    }// end let viewStateFinishedLoading
    
    let viewStateError: (BeaconSearchViewModel.Error) -> Void = {[weak self] error in
      guard let `self` = self else { return }
      switch error {
      case .artWaltFetch, .beaconScanning:
        self.showAlert(error: error)
      }// end switch case
      self.tableContentView.isHidden = true
      self.loadingView.isHidden = true
      self.distanceView.isHidden = true
      self.noPermissionView.isHidden = true
    }// end let viewStateError
    
    let stateValueHandler: (BeaconSearchViewModel.State) -> Void = { state in
      switch state {
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case .noPermission:
        viewStateNoPermission()
      case let .outOfGeoRange(center):
        viewStateOutOfGeoRange(center)
      case let .inGeoRange(center):
        viewStateInGeoRange(center)
      case .scanning:
        viewStateScanning()
      case .didRangeBeacon:
        viewStateDidRangeBeacon()
      case .finishedScanning:
        viewStateFinishedScanning()
      case let .error(error):
        viewStateFinishedLoading()
        viewStateError(error)
      }// end switch case
    }// end stateValueHandler
    
    var sub: AnyCancellable?
    
    sub = self.viewModel.$state
      .receive(on: RunLoop.main)
      //.dropFirst()
      .sink(receiveValue: stateValueHandler)
    guard let stateSub = sub else { return }
    bindings.insert(stateSub)
    
    sub = self.viewModel.$artWaldBeacons
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink {[weak self] completion in
        guard let `self` = self,
              let sub = sub else { return }
        self.bindings.remove(sub)
        switch completion {
        case .finished:
#if DEBUG
          print("finished")
#endif
        case .failure:
#if DEBUG
          print("error: receiving items")
#endif
        }// end switch case
        sub.cancel()
      } receiveValue: {[weak self] artItems in
        guard let `self` = self else { return }
#if DEBUG
        print("receivedValue:")
        print(artItems.debugDescription)
#endif
        self.collectionView.reloadData()
      }// end receive closure
    guard let itemsSub = sub else { return }
    bindings.insert(itemsSub)
  }// end func bind to view model
  
  private func setupViews() -> Void {
    setupActivityIndicator()
    distanceLabel.text = viewModel.distanceLabelText
    loadingLabel.text = viewModel.loadingLabelText
    rightBarButton.title = viewModel.rightBarButtonItemTitleClose
    headerLabel.text = viewModel.header
    descriptionLabel.setTextWithLinks(
      text: viewModel.description,
      links: viewModel.descriptionLinks,
      color: .white)
  }// end func setupViews
  
  /// Handles the tap on `descriptionLabel`
  /// - Parameter gesture: the caller of the function
  @IBAction func tapDescriptionLabel(_ gesture: UITapGestureRecognizer) -> Void {
    guard let label = descriptionLabel,
          let text = label.text,
          let link = viewModel.descriptionLinks.first else { return }
    let linkRange = (text as NSString).range(of: link)
    if gesture.didTapAttributedTextInLabel(label: label,
                                           inRange: linkRange) {
      viewModel.openWeb()
    }// end if
  }// end func tapDescriptionLabel with gesture
  
  @IBAction func closeButtonTouch(_: UIBarButtonItem) -> Void {
    viewModel.closeButtonTouch()
  }// end func closeButtonTouch
  
  @IBAction func openSettings(_: UIButton) -> Void {
    viewModel.openDeviceSettings()
  }// end func openSettings
  
  @IBAction func openWeb(_: UIButton) -> Void {
    viewModel.openWeb()
  }// end func openWeb
  
  @IBAction func openRouteTo(_: UIButton) -> Void {
    showRouteToAlert(geoPoint: viewModel.eventLocation)
  }// func openRouteTo
  
  public func didOpenDeviceSettings() -> Void {
    viewModel.didOpenDeviceSettings()
  }// end public func didOpenDeviceSettings
}// end final class BeaconSearchViewController

// MARK: - lifecycle
extension BeaconSearchViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    bind(to: viewModel)
    self.viewModel.viewDidLoad()
  }// end override func viewDidLoad
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    OSCAMatomoTracker.shared.trackPath(["culture"])
    viewModel.viewWillAppear()
  }// end override func viewWillAppear
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    routeButton.layer.cornerRadius = routeButton.frame.size.height / 2
    routeButton.layer.masksToBounds = true
    viewModel.viewDidLayoutSubviews()
  }// end override func viewDidLayoutSubviews
}// end extension final class BeaconSearchViewController

// MARK: UICollectionViewDelegate conformance
extension BeaconSearchViewController: UICollectionViewDelegate {
  func setupCollectionView() -> Void {
    guard let collectionView = collectionView else { return }
    collectionView.delegate = self
  }// end func setupCollectionView
  
  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath) -> Void {
    guard collectionView.delegate === self else { return }
    viewModel.didSelectItem(at: indexPath.row)
  }// end func collectionView didSelectItemAt
}// end extension final class BeaconSearchViewController

// MARK: - UICollectionViewDataSource conformance
extension BeaconSearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    guard collectionView.delegate === self else { return 0 }
    return viewModel.numberOfItemsInSection(section)
  }// end func collection view number of items in section
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard collectionView.delegate === self,
          indexPath.section == 0,
          let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: BeaconSearchCollectionViewCell.reuseIdentifier,
      for: indexPath) as? BeaconSearchCollectionViewCell,
          let object = viewModel.cellForItem(at: indexPath.row)
    else { return UICollectionViewCell() }
    cell.fill(with: object, viewModel.beaconDistance)
    return cell
  }// end func collection view cell for item at
}// end extension final class BeaconSearchViewController

// MARK: - UICollectionViewDelegateFlowLayout conformance
extension BeaconSearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout _: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard collectionView.delegate === self,
          indexPath.section == 0 else { return CGSize(width: 0, height: 0) }
    let width = collectionView.frame.size.width - 32
    return CGSize(width: width, height: 90)
  }// end func collection view size for item at
}// end extension final class BeaconSearchViewController

// MARK: - activity indicator
extension BeaconSearchViewController: ActivityIndicatable {}// end extension final class BeaconSearchViewController

// MARK: - alert
extension BeaconSearchViewController: Alertable {}// end extension final class BeaconSearchViewController

// MARK: - instantiate view controller
extension BeaconSearchViewController: StoryboardInstantiable {
  /// function call: var vc = BeaconSearchViewController.create(viewModel)
  static func create(with viewModel: BeaconSearchViewModel) -> BeaconSearchViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCACultureUI.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }// end static func create
}// end extension final class BeaconSearchViewController

extension BeaconSearchViewController {}
