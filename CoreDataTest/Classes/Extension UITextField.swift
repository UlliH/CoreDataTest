//
//  Extension UITextField.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 25.05.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension UITextField {
    func resizeText(startSize: CGFloat) {
        if let text = self.text{
            self.font = UIFont.systemFontOfSize(startSize)
            let textString = text as NSString
            var widthOfText = textString.sizeWithAttributes([NSFontAttributeName : self.font!]).width
            var widthOfFrame = self.frame.size.width
            // decrease font size until it fits
            while widthOfFrame - 5 < widthOfText {
                let fontSize = self.font!.pointSize
                self.font = self.font?.fontWithSize(fontSize - 0.5)
                widthOfText = textString.sizeWithAttributes([NSFontAttributeName : self.font!]).width
                widthOfFrame = self.frame.size.width
            }
        }
    }
}