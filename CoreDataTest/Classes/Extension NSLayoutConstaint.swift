//
//  Extension NSLayoutConstaint.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 11.02.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    convenience init(
        item1 : UIView,
        attribute1 : NSLayoutAttribute,
        relation : NSLayoutRelation,
        item2 : UIView?,
        attribute2 : NSLayoutAttribute,
        constant : CGFloat,
        multiplier : CGFloat) {
        self.init(
            item: item1,
            attribute: attribute1,
            relatedBy: relation,
            toItem: item2,
            attribute: attribute2,
            multiplier: multiplier,
            constant: constant)
    }

    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
    
}