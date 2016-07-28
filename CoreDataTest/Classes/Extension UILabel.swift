//
//  Extension UILabel.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 06.12.15.
//  Copyright © 2015 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(badgeText: String, color: UIColor = UIColor.redColor(), fontSize: CGFloat = UIFont.smallSystemFontSize()) {
        self.init()
        text = " \(badgeText) "
        textColor = UIColor.whiteColor()
        backgroundColor = color
        
        font = UIFont.systemFontOfSize(fontSize)
        layer.cornerRadius = fontSize * CGFloat(0.6)
        clipsToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
    }
}
