//
//  UIFont+Extensions.swift
//
//  Created by Jorge Ouahbi on 17/11/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension UIFont {
    func stringSize(s:String,size:CGSize) -> CGSize {
        return UIFont.stringSize(s: s,fontName: fontName,size: size)
    }
    
    static func stringSize(s:String,fontName:String,size:CGSize) -> CGSize {
        for i in (1...50).reversed() {
            let d = [NSAttributedStringKey.font:UIFont(name:fontName, size:CGFloat(i))!]
            let sz = (s as NSString).size(withAttributes: d)
            if sz.width <= size.width && sz.height <= size.height {
                return sz
            }
        }
        print("'\(s)' do not fit in \(size)")
        return CGSize.zero
    }
}
