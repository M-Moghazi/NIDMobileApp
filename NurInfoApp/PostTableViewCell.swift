//
//  PostTableViewCell.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/22/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorJobTitle: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var postBody: UILabel!
    @IBOutlet weak var likeBtnLbl: UIButton!
    @IBOutlet weak var likesCountLbl: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var editBtnLbl: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeBtnLbl.setTitleColor(.clear , for: .normal)
        
        cardView.layer.cornerRadius = 2
        cardView.layer.masksToBounds = true
        
        authorAvatar.layer.borderColor = UIColor.init(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1.0).cgColor
        authorAvatar.layer.borderWidth = 1
        authorAvatar.layer.cornerRadius = 5
        authorAvatar.layer.masksToBounds = true
        authorAvatar.contentMode = .scaleAspectFit
        
        pic.layer.cornerRadius = 2
        pic.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    @IBAction func likeBtnClick(_ sender: Any) {
        let title = (sender as! UIButton).title(for: .normal)
        
        if title == "unlike" {
            let object = PFObject(className: "Likes")
            object["to"] = uuid.text
            object["by"] = PFUser.current()?.username
            object.saveInBackground { (done: Bool, error: Error?) in
                if error == nil {
                    self.likeBtnLbl.setBackgroundImage(#imageLiteral(resourceName: "like.png"), for: .normal)
                    self.likeBtnLbl.setTitle("like", for: .normal)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "like"), object: nil)
                }
            }
        } else {
            let likeQuery = PFQuery(className: "Likes")
            likeQuery.whereKey("to", equalTo: uuid.text!)
            likeQuery.whereKey("by", equalTo: PFUser.current()!.username!)
            
            likeQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                for object in objects! {
                    object.deleteInBackground(block: { (done: Bool, error: Error?) in
                        if done {
                            self.likeBtnLbl.setBackgroundImage(#imageLiteral(resourceName: "unlike.png"), for: .normal)
                            self.likeBtnLbl.setTitle("unlike", for: .normal)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "like"), object: nil)
                        }
                    })
                }
            })
        }
    }
}
