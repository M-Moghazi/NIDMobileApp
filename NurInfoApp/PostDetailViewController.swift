//
//  PostDetailViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 7/30/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

var PDTitle = String()
var PDAuthor = String()
var PDJob = String()
var PDAuthorPic = UIImage()
var PDDate = String()
var PDimage = UIImage()
var PDBody = String()

var PDcommentuuid = [String]()
var PDcommentowner = [String]()

class PostDetailViewController: UIViewController {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorJobTitle: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postBody: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorAvatar.layer.borderColor = UIColor.init(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1.0).cgColor
        authorAvatar.layer.borderWidth = 1
        authorAvatar.layer.cornerRadius = authorAvatar.frame.width/2
        authorAvatar.clipsToBounds = true
        authorAvatar.contentMode = .scaleAspectFit
        
        postImage.layer.cornerRadius = 2
        postImage.clipsToBounds = true
        
        postTitle.text = PDTitle
        authorAvatar.image = PDAuthorPic
        authorName.text = PDAuthor
        authorJobTitle.text = PDJob
        postDate.text = PDDate
        postImage.image = PDimage
        postBody.text = PDBody
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PostDetailViewController.imageTapped(gesture:)))
        
        postImage.addGestureRecognizer(tapGesture)
        postImage.isUserInteractionEnabled = true
    }
    
    func imageTapped(gesture: UITapGestureRecognizer) {
        
        let picView = UIImageView(image: postImage.image)
        picView.frame = UIScreen.main.bounds
        picView.backgroundColor = .black
        picView.contentMode = .scaleAspectFit
        picView.isUserInteractionEnabled = true
        
        let dismissSwip = UISwipeGestureRecognizer(target: self, action: #selector(PostDetailViewController.dismissImage(gesture:)))
        dismissSwip.direction = [.up, .down ]
        picView.addGestureRecognizer(dismissSwip)
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(PostDetailViewController.dismissImage(gesture:)))
        picView.addGestureRecognizer(dismissTap)
        self.view.addSubview(picView)

        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func dismissImage(gesture: UITapGestureRecognizer) {
        
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
        gesture.view?.removeFromSuperview()
    }


}
