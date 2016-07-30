//
//  Thumbnail.swift
//  Codinator
//
//  Created by Vladimir Danila on 6/20/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

final public class Thumbnail: NSObject {

    static let sharedInstance = Thumbnail()
    
    private lazy var dirImage: UIImage = #imageLiteral(resourceName: "dir")
    private lazy var playGroundImageImage: UIImage = #imageLiteral(resourceName: "CnPlaygroundProj")
    private lazy var projectImage: UIImage = #imageLiteral(resourceName: "cnProj")

    private lazy var htmlImage: UIImage = #imageLiteral(resourceName: "html")
    private lazy var jsImage: UIImage = #imageLiteral(resourceName: "js")
    private lazy var cssImage: UIImage = #imageLiteral(resourceName: "css")
    private lazy var ukImage: UIImage = #imageLiteral(resourceName: "generic")
    private lazy var txtImage: UIImage = #imageLiteral(resourceName: "txt")
    private lazy var swiftImage: UIImage = #imageLiteral(resourceName: "swift")
    private lazy var fontImage: UIImage = #imageLiteral(resourceName: "font")
    private lazy var vectorImage: UIImage = #imageLiteral(resourceName: "vector")
    private lazy var phpImage: UIImage = #imageLiteral(resourceName: "php")
    private lazy var lessImage: UIImage = #imageLiteral(resourceName: "less")
    private lazy var zipImage: UIImage = #imageLiteral(resourceName: "zip")
    private lazy var soundImage: UIImage = #imageLiteral(resourceName: "sound")

    
    
    /// Returns the related thumnail for the corresponding file
    public func file(with url: URL, size: CGSize = CGSize(width: 128, height: 128)) -> UIImage {
        
        
        let fileExtension: String! = url.pathExtension == "icloud" ? try! url.deletingPathExtension().pathExtension : url.pathExtension
        
        
        switch fileExtension {
            
        case "png", "jpg", "jpeg", "gif", "PNG", "JPG", "JPEG", "GIF":
            
            guard let image = UIImage(contentsOfFile: url.path!) else { return ukImage }
            return image
            
        case "ttf", "oet", "otf", "woff":
            return self.fontImage
            
        case "svg", "inkpad", "vn", "vectornator":
            return self.vectorImage
            
        case "html":
            return self.htmlImage
            
        case "cnProj":
            return projectThumbnail(for: url, size: size)
            
        case "css":
            return self.cssImage
            
        case "js":
            return self.jsImage
            
        case "php":
            return self.phpImage
            
        case "txt":
            return self.txtImage
            
        case "less":
            return self.lessImage
            
        case "pdf":
            return self.pdf(with: url)
            
        case "swift":
            return self.swiftImage
            
        case "zip":
            return self.zipImage
            
        case "cnPlay":
            return self.playGroundImageImage
            
        case "mp3", "mp4", "wav", "aiff":
            return self.soundImage
            
        default:
            return self.ukImage
        }
        
        
        
        
    }

    /// Checks if url is a Dir
    public func isDir(at url: URL) -> Bool {
        let path = url.path!
        var isDir: ObjCBool = false
        
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: path, isDirectory: &isDir) && isDir
    }
    
    
    
    // MARK: - Dynamic Thumbnails 
    
    private func projectThumbnail(for url: URL, size: CGSize) -> UIImage {
        guard let favIconPath = try!
            url.appendingPathComponent("Assets", isDirectory: true)
                .appendingPathComponent("favicon.png", isDirectory: false).path else {
                    return projectImage
        }
        
        let fileExists = FileManager.default.fileExists(atPath: favIconPath)
        
        if fileExists {
            guard let image = UIImage(contentsOfFile: favIconPath) else { return projectImage }
            
            
            // if image is bigger than anticipated
            if image.size.height > size.height || image.size.width > size.width {
                let preferedSize = UIScreen.main().scale > 1.0 ? size.width * 3 : size.width
                
                let image = resized(image: image, width: preferedSize)
                return image
            }
            
            return image
        }
        
        return projectImage
        
    }
    
    
    /// Generates a thumbnail for a PDF file 
    private func pdf(with url: URL, size: CGSize = CGSize(width: 110, height: 140)) -> UIImage {
        guard let pdfDocument = CGPDFDocument(url) else {
            return UIImage()
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        context?.translate(x: 0.0, y: rect.size.height)
        context?.scale(x: 1.0, y: -1.0)
        
        context?.setFillColor(gray: 1.0, alpha: 1.0)
        context?.fill(rect)
        
        let page = pdfDocument.page(at: 1)
        let pdfTransform = page?.getDrawingTransform(.mediaBox, rect: rect, rotate: 0, preserveAspectRatio: true)
        
        context?.concatCTM(pdfTransform!)
        
        context?.drawPDFPage(page!)
        
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        
        context?.restoreGState()
        
        UIGraphicsEndImageContext()

        
        
        return thumbnailImage!
    }
    
    private func resized(image sourceImage: UIImage, width scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    public func cropped(image : UIImage, size : CGSize) -> UIImage? {
    
        let refWidth : CGFloat = CGFloat(image.cgImage!.width)
        let refHeight : CGFloat = CGFloat(image.cgImage!.height)
        
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        let imageRef = image.cgImage!.cropping(to: cropRect)
        
        let cropped : UIImage = UIImage(cgImage: imageRef!, scale: 0, orientation: image.imageOrientation)
        
        
        return cropped
    }


}
