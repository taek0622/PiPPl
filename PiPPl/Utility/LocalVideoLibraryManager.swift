//
//  LocalVideoLibraryManager.swift
//  PiPPl
//
//  Created by 김민택 on 1/18/24.
//

import Photos
import UIKit

class LocalVideoLibraryManager: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {

    @Published var videos = [Video]()
    @Published var videoLoadingProgress: Double = 0.0
    @Published var isLoading = false
    private var assetFetchResult: PHFetchResult<PHAsset>?

    var status: PHAuthorizationStatus {
        get {
            PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func configureGallery() async {
        guard let collection = requestVideoAlbums().firstObject else { return }
        let assets = requestVideos(in: collection)
        self.assetFetchResult = assets
        await updateVideos(assets)
    }

    func requestVideoAlbums() -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: PHFetchOptions())
    }

    func requestVideos(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
    }

    func updateVideos(_ assets: PHFetchResult<PHAsset>) async {
        await MainActor.run {
            self.videoLoadingProgress = 0
            self.isLoading = true
        }

        await withTaskGroup(of: (Int, Video).self) { group in
            for idx in 0..<assets.count {
                let asset = assets.object(at: idx)

                group.addTask {
                    return (idx, Video(asset: asset))
                }
            }

            var updatedResults = [(Int, Video)]()

            for await (idx, video) in group {
                updatedResults.append((idx, video))
                let progress = Double(updatedResults.count) / Double(assets.count)

                await MainActor.run {
                    self.videoLoadingProgress = progress
                }
            }

            let updatedVideos = updatedResults.sorted(by: { $0.0 < $1.0 }).map { $0.1 }

            await MainActor.run {
                self.videos = updatedVideos
                self.isLoading = false
            }
        }
    }

    func thumbnail(for asset: PHAsset) async -> UIImage {
        if let cachedImage = ThumbnailMemoryCache.shared.thumbnail(for: asset) {
            return cachedImage
        }

        if let diskImage = ThumbnailDiskCache.shared.loadThumbnail(for: asset) {
            ThumbnailMemoryCache.shared.setThumbnail(diskImage, for: asset)
            return diskImage
        }

        let requestedImage = await requestThumbnail(for: asset)
        ThumbnailDiskCache.shared.saveThumbnail(requestedImage, for: asset)
        ThumbnailMemoryCache.shared.setThumbnail(requestedImage, for: asset)
        return requestedImage
    }

    func requestThumbnail(for asset: PHAsset) async -> UIImage {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                let manager = PHImageManager.default()
                let thumbnailOption = PHImageRequestOptions()
                thumbnailOption.isSynchronous = false
                thumbnailOption.resizeMode = .exact
                thumbnailOption.deliveryMode = .highQualityFormat
                thumbnailOption.isNetworkAccessAllowed = true
                let size = UIScreen.main.bounds.width / 3
                var didResume = false

                manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: thumbnailOption) { result, info in
                    if let result = result, !didResume {
                        didResume = true
                        continuation.resume(returning: result)
                    }

                    if result == nil, !didResume {
                        didResume = true
                        continuation.resume(returning: UIImage(ciImage: CIImage(color: .gray)))
                    }
                }
            }
        }
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let assetsFetchResult = assetFetchResult, let changes = changeInstance.changeDetails(for: assetsFetchResult) else { return }

        Task {
            self.assetFetchResult = changes.fetchResultAfterChanges

            if changes.hasIncrementalChanges {
                if let removed = changes.removedIndexes {
                    for idx in removed.reversed() {
                        ThumbnailDiskCache.shared.removeThumbnail(for: self.videos[idx].asset)
                        ThumbnailMemoryCache.shared.removeThumbnail(for: self.videos[idx].asset)
                        self.videos.remove(at: idx)
                    }
                }

                if let inserted = changes.insertedIndexes {
                    for idx in inserted {
                        let asset = changes.fetchResultAfterChanges.object(at: idx)
                        let video = Video(asset: asset)
                        self.videos.insert(video, at: idx)
                    }
                }

                if let changed = changes.changedIndexes {
                    for idx in changed {
                        let asset = changes.fetchResultAfterChanges.object(at: idx)
                        let video = Video(asset: asset)
                        self.videos[idx] = video
                    }
                }
            } else {
                await self.updateVideos(changes.fetchResultAfterChanges)
            }
        }
    }
}
