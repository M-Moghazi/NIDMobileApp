//
//  CommentCell.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/24/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.borderColor = UIColor.init(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1.0).cgColor
        avatar.layer.borderWidth = 1
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    

}
