import UIKit

extension UIImageView {
    func loadCachedImage(of key: String) {
        if let cachedImage = ImageCacheManager.getObject(forKey: key) {
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global().async {
            guard
                let url = URL(string: key),
                var urlCompoentns = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { return }
            
            urlCompoentns.scheme = "https"
            
            guard
                let imageURL = urlCompoentns.url,
                let imageData = try? Data(contentsOf: imageURL),
                let loadedImage = UIImage(data: imageData)
            else { return }
            
            ImageCacheManager.setObject(image: loadedImage, forKey: key)
            
            DispatchQueue.main.async { [weak self] in
                self?.image = loadedImage
            }
        }
    }
}
