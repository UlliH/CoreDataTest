//
//  DetailColumnCell.swift
//  Visitenkarten
//
//  Created by Ulrich Heinelt on 05.02.16.
//  Copyright © 2016 Ulrich Heinelt. All rights reserved.
//

import UIKit

class DetailColumnCell: UITableViewCell {
    @IBOutlet weak var detail:Details!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtTelefon: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    var isMail = false // EMail?
    var isTelefon = false // Telefon?
    var colsEnabled = false // Zeilen enabled?
}

