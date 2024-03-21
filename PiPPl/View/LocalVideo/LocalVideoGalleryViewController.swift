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
        navigationItem.title = "로컬 비디오"
        initializeCollectionView()
        layout()

        switch libraryManager.status {
        case .notDetermined, .denied, .restricted:
            self.buttonConfig.title = "사진 앨범 접근 권한을 허용해주세요"
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation == .portrait {
            videoCollectionView.collectionViewLayout = configureCompositionalLayout(3)
            layout()
        } else {
            videoCollectionView.collectionViewLayout = configureCompositionalLayout(5)
            layout()
        }
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
        videoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCompositionalLayout(3))
        videoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        videoCollectionView.delegate = self
    }

    private func configureCompositionalLayout(_ itemCountOfRow: Double) -> UICollectionViewCompositionalLayout {
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
        let playerView = LocalPlayerViewController()
        playerView.player = AVPlayer()

        PHCachingImageManager().requestAVAsset(forVideo: videoDataSource.snapshot().itemIdentifiers[indexPath.item], options: PHVideoRequestOptions()) { asset, audioMix, info in
            guard let asset else { return }
            playerView.player?.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        }

        navigationController?.pushViewController(playerView, animated: true)
    }
}

class LocalPlayerViewController: AVPlayerViewController {

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
