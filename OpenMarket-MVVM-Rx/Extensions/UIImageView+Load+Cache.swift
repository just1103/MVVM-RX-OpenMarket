import UIKit

extension UIImageView {
    func loadImage(of key: String) {
        let cacheKey = NSString(string: key)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global().async {
            guard let imageURL = URL(string: key),
                  let imageData = try? Data(contentsOf: imageURL),
                  let loadedImage = UIImage(data: imageData) else {
                return
            }
            ImageCacheManager.shared.setObject(loadedImage, forKey: cacheKey)
            
            DispatchQueue.main.async {
                self.image = loadedImage
            }
        }
    }
}
