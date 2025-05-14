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

    func removeAllThumbnails() async {
        await Task.detached {
            if self.fileManager.fileExists(atPath: self.cacheDirectoryURL.path) {
                try? self.fileManager.removeItem(at: self.cacheDirectoryURL)
                try? self.fileManager.createDirectory(at: self.cacheDirectoryURL, withIntermediateDirectories: true)
            }
        }.value
    }

    func cacheSizeString() -> String {
        var size = cacheSizeInBytes()
        var capacityUnit = SICapacity.Byte

        while size >= 1000 && capacityUnit != .Petabyte {
            size /= 1000
            capacityUnit = SICapacity(rawValue: capacityUnit.rawValue + 1) ?? SICapacity.Petabyte
        }

        return "\(size)" + capacityUnit.capacityString()
    }

    private func fileURL(for asset: PHAsset) -> URL {
        let filename = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
        return cacheDirectoryURL.appendingPathComponent("\(filename)", conformingTo: .jpeg)
    }

    private func cacheSizeInBytes() -> Int64 {
        return folderSize(at: cacheDirectoryURL)
    }

    private func folderSize(at url: URL) -> Int64 {
        var size: Int64 = 0

        if let files = try? FileManager.default.subpathsOfDirectory(atPath: url.path) {
            for file in files {
                let filePath = url.appendingPathComponent(file).path

                if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filePath),
                   let fileSize = fileAttributes[.size] as? NSNumber {
                    size += fileSize.int64Value
                }
            }
        }

        return size
    }

}
