//
//  Utils.swift
//  InvestInfo
//
//  Created by Albert on 20.09.2022.
//

import UIKit

struct Constants {
    static let baseHost = "http://investinfo.freemyip.com"
}

extension UIImage {
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        let resizeFactor = (size.height > size.width) ? heightFactor : widthFactor
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        return resizedImage(newSize: newSize)
    }
    
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        guard let imageRef = self.cgImage?.cropping(to: rect) else { return UIImage() }
        return UIImage(cgImage: imageRef)
    }
    
    func getSquaredImage(sourceImage: UIImage?) -> UIImage? {
        guard let image = sourceImage else { return nil }
        guard image.size.height != image.size.width else { return image }
        
        let shortestSide = min(image.size.height, image.size.width)
        let longestSide = max(image.size.height, image.size.width)
        
        let center = longestSide / 2
        let begin = center - shortestSide / 2
        
        let x = image.size.height < image.size.width ? begin : 0
        let y = image.size.height > image.size.width ? begin : 0
        
        return image.crop(rect: CGRect(x: round(x), y: round(y), width: shortestSide, height: shortestSide))
    }
}
