//
//  ThumbnailDiskCache.swift
//  PiPPl
//
//  Created by 김민택 on 5/11/25.
//

import Photos
import UIKit

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

        if !fileManager.fileExists(atPath: cacheDirectoryURL.path) {
            try? fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
        }

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

    func removeAllThumbnails() {
        guard fileManager.fileExists(atPath: cacheDirectoryURL.path) else { return }
        try? fileManager.removeItem(at: cacheDirectoryURL)
        try? fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
    }

    private func fileURL(for asset: PHAsset) -> URL {
        let filename = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
        return cacheDirectoryURL.appendingPathComponent("\(filename)", conformingTo: .jpeg)
    }

}
