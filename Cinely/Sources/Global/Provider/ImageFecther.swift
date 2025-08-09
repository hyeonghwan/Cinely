//
//  ImageFecther.swift
//  Cinely
//
//  Created by hwan on 8/8/25.
//

import UIKit
import Kingfisher
import RxSwift

final class ImagePrefetchProvider {
    static let shared = ImagePrefetchProvider()
    
    private var currentPrefetcher: ImagePrefetcher?
    private var size: CGSize?
    
    private lazy var options: KingfisherOptionsInfo = [
        .processor(DownsamplingImageProcessor(size: size ?? CGSize(width: 300, height: 300))),
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage,
        .memoryCacheExpiration(.days(7)),
        .diskCacheExpiration(.days(30)),
        .callbackQueue(.mainAsync)
    ]
    
    private init() { }
    
    func setCacheSize(size: CGSize) {
        self.size = size
    }
    
    func prefetchImages(for models: [String]) {
        currentPrefetcher?.stop()
        
        let urls = models.compactMap { model -> URL? in
            URL(string: model)
        }
        
        guard !urls.isEmpty else {
            return
        }
        
        currentPrefetcher = ImagePrefetcher(urls: urls, options: options, completionHandler:  { skip, failed, completed in
            #if DEBUG
            print("ImagePrefetchProvider: Completed: \(completed.count), Skipped: \(skip.count), Failed: \(failed.count)")
            #endif
        })
        
        currentPrefetcher?.start()
    }
    
    func stopPrefetching() {
        currentPrefetcher?.stop()
        currentPrefetcher = nil
    }
    
    func isImageCached(for filePath: String) -> Bool {
        guard let url = URL(string: filePath) else { return false }
        return ImageCache.default.imageCachedType(forKey: url.absoluteString).cached
    }
    
    func getCachedImageCount() -> Int {
        return ImageCache.default.memoryStorage.config.countLimit
    }
    
    func clearMemoryCache() {
        ImageCache.default.clearMemoryCache()
    }
    
    func clearDiskCache() {
        ImageCache.default.clearDiskCache()
    }
}
