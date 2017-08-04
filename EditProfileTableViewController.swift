//
//  EditProfileTableViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/20/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var changeAvaLbl: UIButton!
    
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var jobTitleTxt: UITextField!
    
    @IBOutlet weak var phoneNoTxt: UITextField!
    
    @IBOutlet weak var saveBtnLbl: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.register(defaults: ["avatar" : false])
        UserDefaults.standard.synchronize()
        
        fullNameTxt.delegate = self
        jobTitleTxt.delegate = self
        phoneNoTxt.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        
        if PFUser.current() != nil {
            usernameLbl.text! = PFUser.current()?.object(forKey: "username") as! String
            fullNameTxt.text! = PFUser.current()?.object(forKey: "fullName") as! String
            jobTitleTxt.text! = PFUser.current()?.object(forKey: "jobTitle") as! String
            phoneNoTxt.text! = PFUser.current()?.object(forKey: "mobile") as! String
            
            let avatarFile = PFUser.current()?.object(forKey: "avatar") as! PFFile
            avatarFile.getDataInBackground(block: { (data: Data?, error: Error?) in
                if error == nil {
                    
                    self.avatar.image = UIImage(data: data!)
                    self.avatar.contentMode = .scaleAspectFit
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        self.tableView.reloadData()

        avatar.layer.borderColor = UIColor.init(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1.0).cgColor
        avatar.layer.borderWidth = 1
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.layer.masksToBounds = true
    }
    
    func hideKeyboard() {
        tableView.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveBtnLbl.isEnabled = true
    }
    
    func enableTxtField(enabled: Bool) {
        fullNameTxt.isUserInteractionEnabled = enabled
        jobTitleTxt.isUserInteractionEnabled = enabled
        phoneNoTxt.isUserInteractionEnabled = enabled
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameTxt {
            jobTitleTxt.becomeFirstResponder()
        }
        if textField == jobTitleTxt {
            phoneNoTxt.becomeFirstResponder()
        }
        if textField == phoneNoTxt {
            phoneNoTxt.resignFirstResponder()
        }
        return true
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        } else {
            return 1
        }
    }
    @IBAction func changeAvatarBtn(_ sender: Any) {
        
        let imageAlert = UIAlertController(title: "Edit Profile Picture", message: "change or remove your profile picture", preferredStyle: .actionSheet)
        let deleteImage = UIAlertAction(title: "Remove", style: .destructive) { (delete) in
            self.avatar.image = UIImage(named: "profilepic.jpg")
            
            UserDefaults.standard.set(false, forKey: "avatar")
            UserDefaults.standard.synchronize()
            
            self.saveBtnLbl.isEnabled = true
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        let chooseImage = UIAlertAction(title: "Choose Photo", style: .default) { (choose) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        imageAlert.addAction(chooseImage)
        
        if UserDefaults.standard.bool(forKey: "avatar") == true {
            imageAlert.addAction(deleteImage)
        }
        
        imageAlert.addAction(cancel)
        
        self.present(imageAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        avatar.image = info[UIImagePickerControllerEditedImage] as? UIImage
        saveBtnLbl.isEnabled = true
        
        UserDefaults.standard.set(true, forKey: "avatar")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        
        self.view.endEditing(true)
        
        enableTxtField(enabled: false)
        
        saveBtnLbl.isEnabled = false
        
        let trimmedName = fullNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedJob = jobTitleTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName!.isEmpty || trimmedJob!.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Name and Job title are required", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            enableTxtField(enabled: true)
        } else {
            if let currentUser = PFUser.current() {
                currentUser["fullName"] = trimmedName!
                currentUser["jobTitle"] = trimmedJob!
                currentUser["email"] = currentUser.username
                
                if phoneNoTxt.text!.isEmpty {
                    currentUser["mobile"] = ""
                } else {
                    // TODO: validate mobile No
                    currentUser["mobile"] = phoneNoTxt.text!
                }
                
                let avatarData = UIImageJPEGRepresentation(avatar.image!, 0.5)
                let avatarFile = PFFile(name: "avatar.jpg", data: avatarData!)
                currentUser["avatar"] = avatarFile!
                currentUser.saveInBackground(block: { (done: Bool, error: Error?) in
                    if done {
                        self.navigationController?.popViewController(animated: true)
                        self.enableTxtField(enabled: true)
                    } else {
                        print(error!.localizedDescription)
                        self.enableTxtField(enabled: true)
                    }
                })

            }
        }
    }

}
