//
//  ViewController.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import UIKit
import OSCAEssentials
import Combine

final class MainViewController: UIViewController, Alertable {
  @IBOutlet weak var collectionView: UICollectionView?
  
  @IBOutlet weak var tableContentView: UIView?
  
  @IBOutlet weak var noPermissionView: UIView?
  
  @IBOutlet weak var distanceView: UIView?
  
  @IBOutlet weak var routeButton: UIView?
  
  @IBOutlet weak var descriptionLabel: UILabel?
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var viewModel: MainViewModel!
  
  private var bindings = Set<AnyCancellable>()
  
  private func bind(to viewModel: MainViewModel) {
    let viewStateLoading: () -> Void = { [weak self] in
      guard let `self` = self else { return }
      self.showActivityIndicator()
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.hideActivityIndicator()
    }// end let viewStateFinishedLoading
    
    let viewStateScanning: () -> Void = { [weak self] in
      guard let `self` = self else { return }
      self.showActivityIndicator()
    }// end let viewStateLoading
    
    let viewStateFinishedScanning: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.hideActivityIndicator()
    }// end let viewStateFinishedLoading
    
    let viewStateError: (MainViewModel.Error) -> Void = {[weak self] error in
      guard let `self` = self else { return }
      switch error {
      case .artWaltFetch, .beaconScanning:
        self.showAlert(error: error)
      }// end switch case
    }// end let viewStateError
    
    let stateValueHandler: (MainViewModel.State) -> Void = { state in
      switch state {
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case .scanning:
        viewStateScanning()
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
      }// end receive closure
    guard let itemsSub = sub else { return }
    bindings.insert(itemsSub)
  }// end func bind to view model
  
  private func setupView() -> Void {
    guard let descriptionLabel = descriptionLabel else { return }
    descriptionLabel.setTextWithLinks(text: viewModel.mainDescriptionLabelText,
                                      links: ["quartier-wald.de"],
                                      color: .white)
  }// end func setupView
  
  private func openWeb(_ url: URL) {
    viewModel.openWeb(url)
  }// end private func openWeb
  
  /// Handles the tap on `descriptionLabel`
  /// - Parameter gesture: the caller of the function
  @IBAction func tapDescriptionLabel(_ gesture: UITapGestureRecognizer) {
    guard let label = descriptionLabel,
          let text = label.text,
          let url = URL(string: "https://www.quartier-wald.de") else { return }
    let linkRange = (text as NSString).range(of: "quartier-wald.de")
    
    if gesture.didTapAttributedTextInLabel(label: label,
                                           inRange: linkRange) {
      openWeb(url)
    }// end if
  }// end func tapDescriptionLabel with gesture
  
  @IBAction func closeButtonTouch(_: UIBarButtonItem) {
    viewModel.closeButtonTouch()
  }// end func closeButtonTouch
  
  @IBAction func openSettings(_: UIButton) {
    viewModel.openDeviceSettings()
  }// end func openSettings
  
}// end final class MainViewController

// MARK: - lifecycle
extension MainViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bind(to: viewModel)
    viewModel.viewDidLoad()
  }// end override func viewDidLoad
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.viewWillAppear()
  }// end override func viewWillAppear
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    viewModel.viewDidLayoutSubviews()
  }// end override func viewDidLayoutSubviews
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.viewDidDisappear()
  }// end override func viewDidDisappear
}// end extension final class MainViewController

// MARK: UICollectionViewDelegate conformance
extension MainViewController: UICollectionViewDelegate {
  func setupCollectionView() -> Void {
    guard let collectionView = collectionView else { return }
    collectionView.delegate = self
  }// end func setupCollectionView
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
    return
  }// end func collectionView didSelectItemAt
}// end extension final class MainViewController

// MARK: - UICollectionViewDataSource conformance
extension MainViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard collectionView.delegate === self else { return 0 }
    return 0
  }// end func collection view number of items in section
}// end extension final class MainViewController

// MARK: - UICollectionViewDelegateFlowLayout conformance
extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }// end func collectionView cell for item at index path
}// end extension final class MainViewController

// MARK: - activity indicator
extension MainViewController: ActivityIndicatable {}// end extension final class MainViewController

// MARK: - alert
extension MainViewController: Alertable {}// end extension final class MainViewController

// MARK: - instantiate view controller
extension MainViewController: StoryboardInstantiable {
  /// function call: var vc = OSCAColorPaletteViewController.create(viewModel)
  static func create(with viewModel: MainViewModel) -> MainViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = Bundle(for: Self.self)
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }// end static func create
}// end extension final class MainViewController
