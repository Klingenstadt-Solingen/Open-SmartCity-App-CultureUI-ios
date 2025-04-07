//
//  BeaconDetailsViewController.swift
//  Solingen
//
//  Created by MAMMUT Nithammer on 19.09.20.
//  Reviewed by Stephan Breidenbach on 27.09.22
//  Copyright © 2020 Stadt Solingen. All rights reserved.
//

import UIKit
import OSCAEssentials
import OSCACulture
import Combine

final class BeaconDetailsViewController: UIViewController {
  /// controller's activity indicator
  public lazy var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView.init(style: .large,
                                                                                            color: .darkGray)
  @IBOutlet private var topImageView: UIImageView!
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var topTitleLabel: UILabel!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var bodyTextView: UITextView!
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var textViewHeight: NSLayoutConstraint!
  
  @IBOutlet var imageViewGestureRecognizer: UITapGestureRecognizer!
  
  private var viewModel: BeaconDetailsViewModel!
  /// controller's bindings
  private var bindings: Set<AnyCancellable> = Set<AnyCancellable>()
  
  private var dataSource: BeaconDetailsViewController.DataSource!
  
  private var tableDataSource: BeaconDetailsViewController.TableDataSource!
  
  private func bind(to viewModel: BeaconDetailsViewModel) -> Void {
    let viewStateLoading: () -> Void = { [weak self] in
      guard let `self` = self,
            let collectionView = self.collectionView,
            let tableView = self.tableView,
            let topImageView = self.topImageView else { return }
      self.showActivityIndicator()
      collectionView.isUserInteractionEnabled = false
      tableView.isUserInteractionEnabled = false
      topImageView.isUserInteractionEnabled = false
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = { [weak self] in
      guard let `self` = self,
            let collectionView = self.collectionView,
            let tableView = self.tableView,
            let topImageView = self.topImageView else { return }
      self.hideActivityIndicator()
      collectionView.isUserInteractionEnabled = true
      tableView.isUserInteractionEnabled = true
      topImageView.isUserInteractionEnabled = true
    }// end let viewStateFinishedLoading
    
    let viewStateError: (BeaconDetailsViewModel.Error) -> Void = {[weak self] error in
      guard let `self` = self else { return }
      switch error {
      case .imageFetch:
        self.showAlert(error: error)
      }// end switch case
    }// end let viewStateError
    
    let stateValueHandler: (BeaconDetailsViewModel.State) -> Void = { state in
      switch state {
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case let .error(error):
        viewStateFinishedLoading()
        viewStateError(error)
      }// end switch case
    }// end let stateValueHandler
    
    var sub: AnyCancellable?
    
    sub = self.viewModel
      .$state
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: stateValueHandler)
    guard let stateSub = sub else { return }
    bindings.insert(stateSub)
    
    sub = self.viewModel
      .$titleImageThumbData
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
      } receiveValue: {[weak self] titleImageData in
        guard let `self` = self else { return }
        if let titleImageData = titleImageData {
          self.topImageView.image = UIImage(data: titleImageData)
        } else {
          self.topImageView.image = UIImage.placeholder
        }// end if
      }// end receive closure
    guard let titleImageThumbDataSub = sub else { return }
    bindings.insert(titleImageThumbDataSub)
  }// end private func bind to view model
  
  private func setupViews() {
    setupTopImageView()
    setupTextView()
    configureDataSource()
    updateSections()
    setupCollectionView()
    configureTableDataSource()
    updateTableSections()
    setupTableView()
    topTitleLabel.text = viewModel.topTitle
    titleLabel.text = viewModel.artWaldItem?.hotspotTitle
    setBodyText()
  }// end private func setupViews
  
  @objc
  func showImageGallery() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.showImageGallery()
  }// end func showImageGallery
  
  func setupTopImageView() -> Void {
    guard let topImageView = topImageView else { return }
    topImageView.isUserInteractionEnabled = false
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(showTitleImage))
    topImageView.addGestureRecognizer(singleTap)
  }// end func setupTopImageView
  
  @objc
  func showTitleImage() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.showTitleImage()
  }// end func showTitleImage
  
  private func setBodyText() -> Void {
    bodyTextView.isEditable = false
    bodyTextView.isScrollEnabled = false
    bodyTextView.textContainerInset = .zero
    bodyTextView.textContainer.lineFragmentPadding = 0
    let sizeThatShouldFitTheContent = bodyTextView.sizeThatFits(bodyTextView.frame.size)
    textViewHeight.constant = sizeThatShouldFitTheContent.height
    
    if #available(iOS 13.0, *) {
      guard let attrString = try? NSMutableAttributedString(
        HTMLString: viewModel.htmlString,
        color: .label)
      else { return }
      bodyTextView.attributedText = attrString
    } else {
      guard let attrString = try? NSMutableAttributedString(
        HTMLString: viewModel.htmlString)
      else { return }
      bodyTextView.attributedText = attrString
    }// end if
    bodyTextView.linkTextAttributes = [.foregroundColor: UIColor.primary]
    
    textViewHeight.constant = bodyTextView.sizeThatFits(bodyTextView.frame.size).height
    view.layoutIfNeeded()
  }// end func setBodyText
  
}// end final class BeaconDetailsViewController

// MARK: - lifecycle
extension BeaconDetailsViewController {
  override func viewDidLoad() -> Void {
    super.viewDidLoad()
    setupViews()
    bind(to: self.viewModel)
    self.viewModel.viewDidLoad()
  }// end override func viewDidLoad
  
  override func viewDidLayoutSubviews() -> Void {
    super.viewDidLayoutSubviews()
    textViewHeight.constant = bodyTextView.sizeThatFits(bodyTextView.frame.size).height
    view.layoutIfNeeded()
  }// end override func viewDidLayoutSubviews
}// end extension final class BeaconDetailsViewController

// MARK: - activity indicator
extension BeaconDetailsViewController: ActivityIndicatable {}// end extension final class BeaconDetailsViewController

// MARK: - alert
extension BeaconDetailsViewController: Alertable {}// end extension final class BeaconDetailsViewController

// MARK: - instantiate view controller
extension BeaconDetailsViewController: StoryboardInstantiable {
  /// function call: var vc = BeaconDetailsViewController.create(viewModel)
  static func create(with viewModel: BeaconDetailsViewModel) -> BeaconDetailsViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCACultureUI.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }// end static func create
}// end extension final class BeaconDetailsViewController

// MARK: - UICollectionViewDiffableDataSource
extension BeaconDetailsViewController {
  typealias DataSource = UICollectionViewDiffableDataSource<BeaconDetailsViewModel.Section, URL>
  typealias Snapshot = NSDiffableDataSourceSnapshot<BeaconDetailsViewModel.Section, URL>
  private func configureDataSource() -> Void {
    guard let collectionView = collectionView else { return }
    dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { [weak self] (collectionView, indexPath, url) -> UICollectionViewCell in
        guard let `self` = self,
              let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: BeaconDetailsImageGalleryCollectionViewCell.reuseIdentifier,
          for: indexPath) as? BeaconDetailsImageGalleryCollectionViewCell
        else { return UICollectionViewCell() }
        let dataModule = self.viewModel.dataModule
        let imageCache = self.viewModel.imageDataCache
        cell.viewModel = BeaconDetailsCollectionCellViewModel(imageCache: imageCache,
                                                              imageGalleryURLThumb: url,
                                                              dataModule: dataModule,
                                                              at: indexPath.row)
        return cell
      })// end DataSourceConstructor
  }// end private func configureDataSource
  
  private func updateSections() -> Void {
    let urls = viewModel.updateSections()
    var snapshot = BeaconDetailsViewController.Snapshot()
    snapshot.appendSections([.galleryImageThumbURLs])
    snapshot.appendItems(urls)
    dataSource.apply(snapshot, animatingDifferences: true)
  }// end private func updateSections
}// end extension final class BeaconDetailsViewController

// MARK: - UICollectionViewDelegate conformance
extension BeaconDetailsViewController: UICollectionViewDelegate {
  func setupCollectionView() -> Void {
    guard let collectionView = collectionView else { return }
    collectionView.delegate = self
    
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(showImageGallery))
    collectionView.addGestureRecognizer(singleTap)
    
  }// end func setupCollectionView
}// end extension final class BeaconDetailsViewController

// MARK: - UITableViewDiffableDataSource
extension BeaconDetailsViewController {
  private typealias TableDataSource = UITableViewDiffableDataSource<BeaconDetailsViewModel.TableSection, OSCAArtWald.Artist>
  private typealias TableSnapshot = NSDiffableDataSourceSnapshot<BeaconDetailsViewModel.TableSection, OSCAArtWald.Artist>
  private func configureTableDataSource() -> Void {
    guard let tableView = tableView else { return }
    tableDataSource = TableDataSource(
      tableView: tableView,
      cellProvider: { [weak self] (tableView, indexPath, artist) -> UITableViewCell in
        guard let `self` = self,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: BeaconDetailsArtistTableViewCell.reuseIdentifier,
                for: indexPath) as? BeaconDetailsArtistTableViewCell
        else { return UITableViewCell() }
        let dataModule = self.viewModel.dataModule
        let imageCache = self.viewModel.imageDataCache
        let actions = BeaconDetailsTableCellViewModel.Actions(showWebsite: self.viewModel.showWebsite(from:))
        cell.viewModel = BeaconDetailsTableCellViewModel(imageCache: imageCache ,
                                                         artist: artist,
                                                         dataModule: dataModule,
                                                         at: indexPath.row,
                                                         actions: actions)
        return cell
      })// end DataSourceConstructor
  }// end private func configureTableDataSource
  
  private func updateTableSections() -> Void {
    let artists = viewModel.updateTableSections()
    var tableSnapshot = BeaconDetailsViewController.TableSnapshot()
    tableSnapshot.appendSections([.artists])
    tableSnapshot.appendItems(artists)
    tableDataSource.apply(tableSnapshot, animatingDifferences: true)
  }// end private func updateSections
}// end extension final class BeaconDetailsViewController

// MARK: - UITableViewDelegate confromance
extension BeaconDetailsViewController: UITableViewDelegate {
  func setupTableView() -> Void {
    guard let tableView = tableView else { return }
    tableView.delegate = self
  }// end func setupTableView
}// end extension final class BeaconDetailsViewController

// MARK: - UITextViewDelegate conformance
extension BeaconDetailsViewController: UITextViewDelegate {
  func setupTextView() -> Void {
    guard let bodyTextView = bodyTextView else { return }
    bodyTextView.delegate = self
  }// end setupTextView
  
  func textView(_: UITextView,
                shouldInteractWith URL: URL,
                in _: NSRange,
                interaction _: UITextItemInteraction) -> Bool {
    #warning("TODO: Navigation to WebView")
  /*
    let viewController = SFSafariViewController(url: URL)
    viewController.preferredControlTintColor = .primary
    // MARK: Missing extension UIViewController
    present(viewController, animated: true, hapticNotification: .warning)
    return false
  */
    return true
  }// end func textView
}// end extension final class BeaconDetailsViewController
