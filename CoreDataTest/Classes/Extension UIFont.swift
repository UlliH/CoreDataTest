//
//  Extension UIFont.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 26.01.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension UIFont {
    /*
    class func preferredFontForTextStyleWithScale(style: String, scaleFactor : CGFloat) -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(style)
        let pointSize = fontDescriptor.pointSize * scaleFactor
        let font = UIFont(descriptor: fontDescriptor, size: pointSize)
        return font
    }
    */
    class func preferredFontForTextStylWithScaleAndWidth(style: String, scaleFactor : CGFloat, weigth : CGFloat) -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(style)
        let pointSize = fontDescriptor.pointSize * scaleFactor
        let font = UIFont(descriptor: fontDescriptor, size: pointSize)
        return UIFont.systemFontOfSize(font.pointSize, weight: weigth)
        /* weigth:
        UIFontWeightUltraLight
        UIFontWeightThin
        UIFontWeightLight
        UIFontWeightRegular
        UIFontWeightMedium
        UIFontWeightSemibold
        UIFontWeightBold
        UIFontWeightHeavy
        UIFontWeightBlack
        */
    }
}