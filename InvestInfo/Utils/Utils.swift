//
//  Utils.swift
//  InvestInfo
//
//  Created by Albert on 20.09.2022.
//

import UIKit

struct Constants {
    static let baseHost = "http://161.35.211.1"
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
    func resizedImageIn(rectSize: CGSize) -> UIImage {
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
    
    func getSquared(image: UIImage) -> UIImage {
        guard image.size.height != image.size.width else { return image }
        
        let shortestSide = min(image.size.height, image.size.width)
        let longestSide = max(image.size.height, image.size.width)
        
        let center = longestSide / 2
        let begin = center - shortestSide / 2
        
        let x = image.size.height < image.size.width ? begin : 0
        let y = image.size.height > image.size.width ? begin : 0
        
        return image.crop(rect: CGRect(x: round(x), y: round(y), width: shortestSide, height: shortestSide))
    }
    
    func getCroppedImage() -> UIImage {
        let newSize = CGSize(width: 100, height: 100)
        let newImage = resizedImageIn(rectSize: newSize)
        return getSquared(image: newImage)
    }
}

extension UIView {
    func rounded(_ cornerRadius: CGFloat = 15) {
        layer.cornerRadius = cornerRadius
    }
    
    func addManualResizing(
        _ subview: UIView,
        topConstant: CGFloat = 8,
        bottomConstant: CGFloat = -8,
        leadingConstant: CGFloat = 16,
        trailingConstant: CGFloat = -16,
        widthConstant: CGFloat? = nil,
        heightConstant: CGFloat? = nil
    ) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomConstant).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstant).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant).isActive = true
        if let widthConstant = widthConstant {
            subview.widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        }
        if let heightConstant = heightConstant {
            subview.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
    }
}

//TODO: Может стоит перейти на привычные нам регистрации по классам? Тогда надо поменять CommonCellVM

protocol ReuseIdentifiable: AnyObject {
    static func reuseIdentifier() -> String
}


extension ReuseIdentifiable {
    static func reuseIdentifier() -> String {
        NSStringFromClass(self)
    }
}

extension UITableViewCell: ReuseIdentifiable {}

extension UITableView {
    func registerCellClass<T: UITableViewCell>(cellClass: T.Type) {
        self.register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier())
    }
    
    func dequeueCellWithClass<T: UITableViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier(), for: indexPath) as? T else {
            fatalError("Error: cell with identifier: \(cellClass.reuseIdentifier()) for index path: \(indexPath) is not \(T.self)")
        }
        return cell
    }
}
