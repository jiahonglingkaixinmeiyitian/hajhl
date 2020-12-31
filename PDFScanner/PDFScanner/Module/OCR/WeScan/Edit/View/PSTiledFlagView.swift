//
//  PSTiledFlagView.swift
//  PDFScanner
//
//  Created by Dfsx on 2020/12/25.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import SVGKit

class PSTiledFlagView: UIView {

    let flagSize = CGSize(width: 30, height: 30)
    var flagCodes = [String]() {
        didSet {
            flagStackView.removeAllSubviews()
            for flagCode in flagCodes {
                let flagView = SVGKFastImageView(svgkImage: SVGKImage(named: flagCode))!
                flagView.snp.makeConstraints { (make) in
                    make.size.equalTo(flagSize)
                }
                flagStackView.addArrangedSubview(flagView)
            }
            flagStackView.layoutIfNeeded()
        }
    }
    
    lazy fileprivate var flagStackView: UIStackView = {
        let _flagStackView = UIStackView()
        _flagStackView.axis = .horizontal
        _flagStackView.spacing = -flagSize.width / 2 // secret ingredient
        return _flagStackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    func setUp() {
        
        backgroundColor = .clear
        addSubview(flagStackView)
        flagStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
