//
//  ImageFilterCell.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class ImageFilterCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    var cellSelected:Bool = false{
        didSet{
            if oldValue != cellSelected{
                self.layer.borderWidth = cellSelected ? 2 : 0
                self.layer.borderColor = UIColor.colorWithHexString(colorString: "#D13D1E").cgColor
            }
        }
    }
    
    
    var image:UIImage?{
        didSet{
            if oldValue != image{
                imageView.image = image
            }
        }
    }
    
    var title:String?{
        didSet{
            if oldValue != title{
                titleLB.text = title
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
