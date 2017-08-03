//
//  makePostViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/22/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

class makePostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var authorJobTitle: UILabel!
    @IBOutlet weak var postTitle: UITextView!
    @IBOutlet weak var postBody: UITextView!
    @IBOutlet weak var makePostLbl: UIButton!
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var PickImage: UIButton!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    let imagePicker = UIImagePickerController()
    
    var imageIsSeleced: Bool = false
    var textBold: Bool = false
    var testItalic: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorAvatar.layer.cornerRadius = authorAvatar.frame.width/2
        authorAvatar.clipsToBounds = true
        authorAvatar.layer.borderColor = UIColor.init(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1.0).cgColor
        authorAvatar.layer.borderWidth = 1
        authorAvatar.contentMode = .scaleAspectFit
        
        postTitle.layer.cornerRadius = 5
        postBody.layer.cornerRadius = 5
        
        postPic.layer.cornerRadius = 5
        postPic.clipsToBounds = true
        
        makePostLbl.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(makePostViewController.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        if PFUser.current() != nil {
            authorName.text! = PFUser.current()?.value(forKey: "fullName") as! String
            authorJobTitle.text! = PFUser.current()?.value(forKey: "jobTitle") as! String
            
            let avatarFile = PFUser.current()?.object(forKey: "avatar") as! PFFile
            avatarFile.getDataInBackground(block: { (data: Data?, error: Error?) in
                if error == nil {
                    self.authorAvatar.image = UIImage(data: data!)
                    self.authorAvatar.contentMode = .scaleAspectFit
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        postTitle.delegate = self
        postBody.delegate = self
        
        postTitle.text = "Write Title Here"
        postTitle.textColor = UIColor.lightGray

        postBody.text = "Write Content Here"
        postBody.textColor = UIColor.lightGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(makePostViewController.imageTapped(gesture:)))
        
        postPic.addGestureRecognizer(tapGesture)
        postPic.isUserInteractionEnabled = true

    }
    
    func imageTapped(gesture: UITapGestureRecognizer) {
        
        let picView = UIImageView(image: postPic.image)
        picView.frame = UIScreen.main.bounds
        picView.backgroundColor = .black
        picView.contentMode = .scaleAspectFit
        picView.isUserInteractionEnabled = true
        if postPic.image != nil {
            let dismissSwip = UISwipeGestureRecognizer(target: self, action: #selector(makePostViewController.dismissImage(gesture:)))
            dismissSwip.direction = [.up, .down ]
            picView.addGestureRecognizer(dismissSwip)
            
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(makePostViewController.dismissImage(gesture:)))
            picView.addGestureRecognizer(dismissTap)
            self.view.addSubview(picView)
            
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func dismissImage(gesture: UITapGestureRecognizer) {
        
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
        gesture.view?.removeFromSuperview()
    }
    
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            
            self.bottomConstrain.constant = keyboardSize.height + 10
            UIView.animate(withDuration: 0.25, animations: {
                () -> Void in self.view.layoutIfNeeded()
            })
        }
    }


    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        self.bottomConstrain.constant = 10
        UIView.animate(withDuration: 0.25, animations: {
            () -> Void in self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func cancelPostBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        view.endEditing(true)
    }
    
    @IBAction func pickImageBtn(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        postPic.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        imageIsSeleced = true
    }
    
    func enableTxtView(enabled: Bool) {
        postTitle.isUserInteractionEnabled = enabled
        postBody.isUserInteractionEnabled = enabled
    }
    
    @IBAction func makePostBtn(_ sender: Any) {
        
        self.view.endEditing(true)
        makePostLbl.isEnabled = false
        enableTxtView(enabled: false)
        
        if (postTitle.text! == "Write Title Here") || (postBody.text! == "Write Content Here") {
            let alert = UIAlertController(title: "Error", message: "Post title and content are required to publish a post", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            makePostLbl.isEnabled = true
            enableTxtView(enabled: true)
            
        } else if (!imageIsSeleced) {
            
            let alert = UIAlertController(title: "Error", message: "Please Select an image", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            makePostLbl.isEnabled = true
            enableTxtView(enabled: true)
            
        } else {
            let post = PFObject(className: "Posts")
            
            post["author"] = PFUser.current()!
            
            post["uuid"] = "\(PFUser.current()!.username!)\(UUID().uuidString))"
            post["title"] = postTitle.text.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            post["body"] = postBody.text.trimmingCharacters(in: .whitespacesAndNewlines)
            post["commentCount"] = "0"
            
            let picData = UIImageJPEGRepresentation(postPic.image!, 0.5)
            let picFile = PFFile(name: "post_pic.jpg", data: picData!)
            post["pic"] = picFile
            
            post.saveInBackground(block: { (done: Bool, error:Error?) in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }

    }

    func textViewDidChange(_ textView: UITextView) {
        if postBody.contentSize.height > 70 && postBody.contentSize.height <= 240 {
            
            let difference = postBody.contentSize.height - postBody.frame.size.height
            postPic.frame.origin.y += difference
            postBody.frame.size.height = postBody.contentSize.height
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor ==  .lightGray {
            textView.text = ""
            textView.textColor = .darkGray
            makePostLbl.isEnabled = true
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if postTitle.text ==  "" {
            postTitle.text = "Write Title Here"
            postTitle.textColor = UIColor.lightGray
        }
        
        if postBody.text == "" {
            postBody.text = "Write Content Here"
            postBody.textColor = UIColor.lightGray
        }
    }

}
