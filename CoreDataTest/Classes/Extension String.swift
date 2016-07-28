//
//  Extension.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 19.09.15.
//  Copyright © 2015 Ulrich Heinelt. All rights reserved.
//

import UIKit

extension String {

    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    var length : Int {
        return self.characters.count
    }
   
    func substringFromIndex(index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }

    func substringToIndex(index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substringToIndex(self.startIndex.advancedBy(index))
    }
}