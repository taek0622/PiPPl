//
//  LocalVideoGalleryViewController.swift
//  PiPPl
//
//  Created by 김민택 on 1/16/24.
//

import AVKit
import Photos
import UIKit

class LocalVideoGalleryViewController: UIViewController {

    // MARK: - Property

    private let libraryManager = LocalVideoLibraryManager.shared
    private var videoDataSource: UICollectionViewDiffableDataSource<String, PHAsset>!
    private var buttonConfig = UIButton.Configuration.plain()
    private let playerView = LocalPlayerViewController()

    // MARK: - View

    private var videoCollectionView: UICollectionView!

    private lazy var collectionEmptyButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton())

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = AppText.localVideo.localized()
        initializeCollectionView()
        layout()
        playerView.delegate = self

        switch libraryManager.status {
        case .notDetermined, .denied, .restricted:
            self.buttonConfig.title = AppText.photoGalleryAccessPermissionButtonText.localized()
            self.collectionEmptyButton.configuration = self.buttonConfig
            self.collectionEmptyButton.addAction(UIAction { _ in self.photoLibraryAuthorization() }, for: .touchUpInside)
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.collectionEmptyButton.isHidden = true
            }
            configureDataSource()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true

        if libraryManager.status == .authorized || libraryManager.status == .limited {
            applySnapshot()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        Task {
            switch await AppVersionManager.shared.checkNewUpdate() {
            case true:
                guard let filePath = Bundle.main.path(forResource: "Properties", ofType: "plist"),
                      let property = NSDictionary(contentsOfFile: filePath),
                      let iTunesID = property["iTunesID"] as? String
                else { return }

                let appStoreOpenURL = "itms-apps://itunes.apple.com/app/apple-store/\(iTunesID)"
                let alert = UIAlertController(title: "구버전 알림", message: "새로운 버전의 앱이 출시 되었습니다.\n업데이트 이후 사용해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "업데이트 하기", style: .default, handler: { action in
                    guard let url = URL(string: appStoreOpenURL) else { return }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }))
                present(alert, animated: true)
            case false:
                break
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videoCollectionView.collectionViewLayout = configureCompositionalLayout()
        layout()
    }

    // MARK: - Method

    private func layout() {
        view.addSubview(videoCollectionView)
        NSLayoutConstraint.activate([
            videoCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            videoCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        view.addSubview(collectionEmptyButton)
        NSLayoutConstraint.activate([
            collectionEmptyButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            collectionEmptyButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func initializeCollectionView() {
        videoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCompositionalLayout())
        videoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        videoCollectionView.delegate = self
    }

    private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        var itemCountOfRow = 3.0

        if UIDevice.current.systemName == "iOS" {
            if UIDevice.current.orientation == .portrait {
                itemCountOfRow = 3
            } else {
                itemCountOfRow = 5
            }
        } else if UIDevice.current.systemName == "iPadOS" {
            if UIDevice.current.orientation == .portrait {
                itemCountOfRow = 5
            } else {
                itemCountOfRow = 7
            }
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/itemCountOfRow), heightDimension: .fractionalWidth(1/itemCountOfRow))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/itemCountOfRow))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(UIScreen.main.bounds.width/200)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func configureDataSource() {
        let videoCellReigistration = UICollectionView.CellRegistration<LocalVideoThumbnailCell, PHAsset> { (cell, indexPath, item) in
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            var thumbnail = UIImage(ciImage: CIImage(color: .gray))

            manager.requestImage(for: item, targetSize: CGSize(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3), contentMode: .aspectFill, options: option) { result, info in
                guard let result else { return }
                thumbnail = result
            }

            cell.configureThumbnail(thumbnail)
            cell.configureVideoPlayTime(item.duration)
        }

        videoDataSource = UICollectionViewDiffableDataSource<String, PHAsset>(collectionView: videoCollectionView, cellProvider: { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: videoCellReigistration, for: indexPath, item: item)
        })
    }

    private func applySnapshot() {
        let videoAlbums = libraryManager.requestVideoAlbums()
        let assets = libraryManager.requestVideos(in: videoAlbums.firstObject ?? PHAssetCollection())

        var snapshot = NSDiffableDataSourceSnapshot<String, PHAsset>()
        snapshot.appendSections(["videos"])
        assets.enumerateObjects { asset, _, _ in
            snapshot.appendItems([asset])
        }

        videoDataSource.apply(snapshot)
    }

    private func photoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                DispatchQueue.main.async {
                    self.collectionEmptyButton.isHidden = true
                    self.configureDataSource()
                }
                self.applySnapshot()
            }
        }
    }

}

extension LocalVideoGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playerView.player = AVPlayer()

        PHCachingImageManager().requestAVAsset(forVideo: videoDataSource.snapshot().itemIdentifiers[indexPath.item], options: PHVideoRequestOptions()) { asset, audioMix, info in
            guard let asset else { return }
            self.playerView.player?.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        }

        navigationController?.pushViewController(playerView, animated: true)
    }
}

class LocalPlayerViewController: AVPlayerViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.removeFromParent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        tabBarController?.tabBar.isHidden = false
    }

}

extension LocalVideoGalleryViewController: AVPlayerViewControllerDelegate {

    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }

}
