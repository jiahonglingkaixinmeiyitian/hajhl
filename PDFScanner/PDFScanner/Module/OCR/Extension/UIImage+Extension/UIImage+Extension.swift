//
//  UIImage+Extension.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/17.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

extension UIImage{
    public func merge(subImage: UIImage, subImageOrigin: CGPoint) -> UIImage?
    {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        subImage.draw(in: CGRect(x: subImageOrigin.x, y: subImageOrigin.y, width: subImage.size.width, height: subImage.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func reSizeImage(size:CGSize)->UIImage? {
        UIGraphicsBeginImageContextWithOptions(size,false, 1);
        self.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height));
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return reSizeImage
    }
     
    func scaleImage(scaleSize:CGFloat)->UIImage? {
        let size = CGSize(width:self.size.width * scaleSize, height:self.size.height * scaleSize)
        return reSizeImage(size: size)
    }
    
    func compress(byte maxLength:Int) -> UIImage {
        guard var data = self.jpegData(compressionQuality: 1) else {
            return self
        }
        if (data.count < maxLength) {
            return self
        }
        //原图大小超过范围，先进行“压处理”，这里 压缩比 采用二分法进行处理，6次二分后的最小压缩比是0.015625，已经够小了
        var max:CGFloat = 1
        var min:CGFloat = 0
        var compression:CGFloat = 1
        for _ in 0..<6 {
            compression = (max + min) / 2;
            data = self.jpegData(compressionQuality:compression)!
            if (Double(data.count) < Double(maxLength) * 0.9) {
                min = compression;
            } else if (data.count > maxLength) {
                max = compression;
            } else {
                break;
            }
        }
        //判断“压处理”的结果是否符合要求，符合要求就over
        var resultImage = UIImage(data: data)!
        if (data.count < maxLength) {
            return resultImage
        }
        
        //缩处理，直接用大小的比例作为缩处理的比例进行处理，因为有取整处理，所以一般是需要两次处理
        var lastDataLength:Int = 0
        while (data.count > maxLength && data.count != lastDataLength) {
            lastDataLength = data.count;
            //获取处理后的尺寸
            
            let ratio:Float = Float(maxLength) / Float(lastDataLength)
            let size = CGSize(width: resultImage.size.width * CGFloat(sqrtf(ratio)), height: resultImage.size.height * CGFloat(sqrtf(ratio)))
            
            //通过图片上下文进行处理图片
            UIGraphicsBeginImageContext(size);
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext();
            data = resultImage.jpegData(compressionQuality: compression)!
        }
        return resultImage;
    }
    
    func compress(byte maxLength:Int) -> Data? {
        guard var data = self.jpegData(compressionQuality: 1) else {
            return nil
        }
        if (data.count < maxLength) {
            return data
        }
        //原图大小超过范围，先进行“压处理”，这里 压缩比 采用二分法进行处理，6次二分后的最小压缩比是0.015625，已经够小了
        var max:CGFloat = 1
        var min:CGFloat = 0
        var compression:CGFloat = 1
        for _ in 0..<6 {
            compression = (max + min) / 2;
            data = self.jpegData(compressionQuality:compression)!
            if (Double(data.count) < Double(maxLength) * 0.9) {
                min = compression;
            } else if (data.count > maxLength) {
                max = compression;
            } else {
                break;
            }
        }
        //判断“压处理”的结果是否符合要求，符合要求就over
        if (data.count < maxLength) {
            return data
        }
        
        //缩处理，直接用大小的比例作为缩处理的比例进行处理，因为有取整处理，所以一般是需要两次处理
        var resultImage = UIImage(data: data)!
        var lastDataLength:Int = 0
        while (data.count > maxLength && data.count != lastDataLength) {
            lastDataLength = data.count;
            //获取处理后的尺寸
            
            let ratio:Float = Float(maxLength) / Float(lastDataLength)
            let size = CGSize(width: resultImage.size.width * CGFloat(sqrtf(ratio)), height: resultImage.size.height * CGFloat(sqrtf(ratio)))
            
            //通过图片上下文进行处理图片
            UIGraphicsBeginImageContext(size);
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext();
            data = resultImage.jpegData(compressionQuality: compression)!
        }
        return data;
    }
}
