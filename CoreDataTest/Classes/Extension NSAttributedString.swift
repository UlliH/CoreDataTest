//
//  Extension NSAttributedString.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 05.04.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func getAttributes() -> [(NSRange, [(String, AnyObject)])] {
        var attributesOverRanges : [(NSRange, [(String, AnyObject)])] = []
        var rng = NSRange()
        var idx = 0
        
        while idx < self.length {
            let foo = self.attributesAtIndex(idx, effectiveRange: &rng)
            var attributes : [(String, AnyObject)] = []
            
            for (k, v) in foo { attributes.append(k, v) }
            attributesOverRanges.append((rng, attributes))
            
            idx = max(idx + 1, rng.toRange()?.endIndex ?? 0)
        }
        return attributesOverRanges
    }
}
