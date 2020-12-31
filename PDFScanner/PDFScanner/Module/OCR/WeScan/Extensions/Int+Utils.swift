//
//  Int+Utils.swift
//  PDFScanner
//
//  Created by Benson Tommy on 2020/12/24.
//  Copyright © 2020 cdants. All rights reserved.
//

import Foundation

extension Int {
    
    var isEven: Bool {
        return self % 2 == 0
    }
    
    var isOdd: Bool {
        return !isEven
    }
}
