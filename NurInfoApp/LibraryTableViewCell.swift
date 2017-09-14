//
//  LibraryTableViewCell.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 8/24/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    @IBOutlet weak var docPic: UIImageView!
    @IBOutlet weak var docTitle: UILabel!
    @IBOutlet weak var docDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
