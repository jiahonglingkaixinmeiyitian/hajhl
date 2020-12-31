//
//  FilterSliderView.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class FilterSliderView: UIView {

    var filterSliderChangeBlock:((_ value:CGFloat)->Void)?
    
    @IBOutlet weak var filterSlider: UISlider!
    @IBOutlet weak var filterSliderLB: UILabel!
    
    @IBAction func filterSliderChange(_ sender: UISlider) {
        self.updateFilterSliderLB()
        self.filterSliderChangeBlock?(CGFloat(sender.value))
    }
    
    func updateFilterSliderLB(){
        var text = ""
        if self.filterSlider.minimumValue < 0{
             text = "\(Int(Float((self.filterSlider.value+abs(self.filterSlider.minimumValue))*100.0)/(abs(self.filterSlider.minimumValue)+self.filterSlider.maximumValue)))%"
        }else{
            text = "\(Int(Float(self.filterSlider.value*100.0)/(self.filterSlider.minimumValue+self.filterSlider.maximumValue)))%"
        }
        self.filterSliderLB.text = text
    }
}
