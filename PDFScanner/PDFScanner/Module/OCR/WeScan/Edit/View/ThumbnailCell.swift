//
//  ThumbnailCell.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/13.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var image:UIImage?{
        didSet{
            if oldValue != image{
                imageView.image = image
            }
        }
    }
    
    override var selectedState: Bool{
        didSet{
            self.imageView.layer.borderWidth = selectedState ? 2 : 1
            self.imageView.layer.borderColor = UIColor.colorWithHexString(colorString: selectedState ? "#D13D1E" : "#D8D8D8") .cgColor
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
