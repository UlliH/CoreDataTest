//
//  ImageItem.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 29.05.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

class ImageItem {
    
    var itemImage:String
    
    init(dataDictionary:Dictionary<String,String>) {
        itemImage = dataDictionary["itemImage"]!
    }
}
