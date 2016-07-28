//
//  DetailCell.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 12.01.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    @IBOutlet weak var lblGruppe: UILabel!
    @IBOutlet weak var txtTelefon: UILabel!
    @IBOutlet weak var lblTelefon: UILabel!
    var showAll:Bool!
    @IBOutlet var gruppeTopSpace: NSLayoutConstraint!
    @IBOutlet var telefonTopSpace: NSLayoutConstraint!
}
