//
//  PSSignatureCell.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/19.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class PSSignatureCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var cellSelected:Bool = false{
        didSet{
            if oldValue != cellSelected{
                self.layer.borderWidth = cellSelected ? 3 : 1
                self.layer.borderColor = (cellSelected ? UIColor.colorWithHexString(colorString: "#D13D1E") : UIColor.colorWithHexString(colorString: "#2D4056", alpha: 0.5)).cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.colorWithHexString(colorString: "#2D4056", alpha: 0.5).cgColor
    }

}
