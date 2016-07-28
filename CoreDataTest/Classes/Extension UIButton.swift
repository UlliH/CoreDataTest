//
//  Extension UIButton.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 06.12.15.
//  Copyright © 2015 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension UIButton {
    var badgeText: String {
        get {
             if self.subviews.count > 0 {
                let label: UILabel = (self.subviews[0] as? UILabel)!
                return label.text!
            } else {
                return ""
            }
        }
        set {
            // > "0", sonst löschen
            if newValue != "0" {
                let badgeLabel = UILabel(badgeText: newValue)
                self.addSubview(badgeLabel)
                self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: badgeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
            } else {
                if self.subviews.count > 0 {
                    for subview in self.subviews {
                        if subview is UILabel {
                            subview.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }

    // show background as rounded rect, like mail addressees
    var rounded: Bool {
        get { return layer.cornerRadius > 0 }
        set { roundWithTitleSize(newValue ? titleSize : 0) }
    }
    
    /// removes other title attributes
    var titleSize: CGFloat {
        get {
            let titleFont = attributedTitleForState(.Normal)?.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as? UIFont
            return titleFont?.pointSize ?? UIFont.buttonFontSize()
        }
        set {
            if UIFont.buttonFontSize() == newValue || 0 == newValue {
                setTitle(currentTitle, forState: .Normal)
            }
            else {
                let attrTitle = NSAttributedString(string: currentTitle ?? "", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(newValue)])
                setAttributedTitle(attrTitle, forState: .Normal)
            }
            
            if rounded {
                roundWithTitleSize(newValue)
            }
        }
    }
    
    private func roundWithTitleSize(size: CGFloat) {
        let padding = size / 4
        layer.cornerRadius = padding + size*1.2/2
        let sidePadding = padding * 1.5
        contentEdgeInsets = UIEdgeInsets(top: padding, left: sidePadding, bottom: padding, right: sidePadding)
    }
}