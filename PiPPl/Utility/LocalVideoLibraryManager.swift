//
//  LocalVideoLibraryManager.swift
//  PiPPl
//
//  Created by 김민택 on 1/18/24.
//

import Foundation
import Photos
import UIKit
import Dispatch

struct Video: Identifiable {
    var id: String { asset.localIdentifier }
    var asset: PHAsset
}

class ThumbnailMemoryCache {

    static let shared = ThumbnailMemoryCache()

    private init() {}

    private var thumbnailCache = NSCache<NSString, UIImage>()

    func thumbnail(for asset: PHAsset) -> UIImage? {
        return thumbnailCache.object(forKey: asset.localIdentifier as NSString)
    }

    func setThumbnail(_ image: UIImage, for asset: PHAsset) {
        thumbnailCache.setObject(image, forKey: asset.localIdentifier as NSString)
    }

    func removeThumbnail(for asset: PHAsset) {
        thumbnailCache.removeObject(forKey: asset.localIdentifier as NSString)
    }

}

class ThumbnailDiskCache {

    static let shared = ThumbnailDiskCache()

    private init() {}

    private let fileManager = FileManager.default

    private var cacheDirectoryURL: URL {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appending(path: "ThumbnailCache", directoryHint: .isDirectory)
    }

    func saveThumbnail(_ image:UIImage, for asset: PHAsset) {
        let url = fileURL(for: asset)

        if !fileManager.fileExists(atPath: cacheDirectoryURL.path) {
            try? fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
        }

        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
    }

    func loadThumbnail(for asset: PHAsset) -> UIImage? {
        let url = fileURL(for: asset)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else { return nil }

        return image
    }

    func removeThumbnail(for asset: PHAsset) {
        let url = fileURL(for: asset)
        try? fileManager.removeItem(at: url)
    }

    private func fileURL(for asset: PHAsset) -> URL {
        let filename = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
        return cacheDirectoryURL.appendingPathComponent("\(filename)", conformingTo: .jpeg)
    }

}

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
