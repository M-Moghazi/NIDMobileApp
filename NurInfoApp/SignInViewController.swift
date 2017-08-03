//
//  SignInViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/18/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var signInLbl: UIButton!
    
    //initalizing sctivity indicator
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    func showAlert (view: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo.layer.cornerRadius = 20
        logo.clipsToBounds = true
        signInLbl.layer.cornerRadius = 10
        signInLbl.clipsToBounds = true
        
        //show keyboard
        usernametxt.becomeFirstResponder()
        
        usernametxt.delegate = self
        passwordtxt.delegate = self
        
        //seeting up activity indicator
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2 )
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernametxt {
            passwordtxt.becomeFirstResponder()
        }
        if textField == passwordtxt {
            passwordtxt.resignFirstResponder()
            SignInAction()
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Regex to validate email
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z]{3,64}+@hamad.qa$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    
    @IBAction func signInbtn_click(_ sender: Any) {
        SignInAction()
    }
    
    func enableTxtField(enabled: Bool) {
            usernametxt.isUserInteractionEnabled = enabled
            passwordtxt.isUserInteractionEnabled = enabled
    }
    
    func SignInAction() {
        activityIndicator.startAnimating()
        signInLbl.isHidden = true
        enableTxtField(enabled: false)
        
        //check if email is correct
        if isValidEmail(testStr: usernametxt.text!.lowercased()) && usernametxt.text!.hasSuffix("@hamad.qa") {
            
            //Trying to log in user
            PFUser.logInWithUsername(inBackground: usernametxt.text!, password: passwordtxt.text!) { (user: PFUser?, error: Error?) in
                if user == nil {
                    //Trying to sign up if log in failed
                    let user = PFUser()
                    user.username = self.usernametxt.text!.lowercased()
                    user.password = self.passwordtxt.text!
                    
                    user.email = self.usernametxt.text!
                    user["fullName"] = ""
                    user["jobTitle"] = ""
                    user["mobile"] = ""
                    
                    let avatarData = UIImageJPEGRepresentation(UIImage(named: "profilepic.jpg")!, 0.5)
                    let avatarFile = PFFile(name: "avatar.jpg", data: avatarData!)
                    user["avatar"] = avatarFile!
                    
                    user.signUpInBackground(block: { (done: Bool, error1: Error?) in
                        if done {
                            self.activityIndicator.stopAnimating()
                            self.signInLbl.isHidden = false
                            self.enableTxtField(enabled: true)
                            print("Signed up")
                            //login user
                            UserDefaults.standard.setValue(user.username, forKey: "username")
                            UserDefaults.standard.synchronize()
                            //move to main
                            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.logIn()
                            self.view.endEditing(true)
                            
                        } else {
                            
                            print(error1!.localizedDescription)
                            self.showAlert(view: self, title: "error", message: error!.localizedDescription)
                            
                            self.activityIndicator.stopAnimating()
                            self.signInLbl.isHidden = false
                            self.enableTxtField(enabled: true)
                        }
                    })
                } else {
                    self.activityIndicator.stopAnimating()
                    self.signInLbl.isHidden = false
                    self.enableTxtField(enabled: true)
                    
                    print("Logged in")
                    UserDefaults.standard.setValue(user?.username, forKey: "username")
                    UserDefaults.standard.synchronize()
                    
                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logIn()
                    self.view.endEditing(true)
                }
            }
        } else {
            
            self.showAlert(view: self, title: "Wrong Email", message: "Please Provide Full Valid Email as in 'email@hamad.qa")
            activityIndicator.stopAnimating()
            signInLbl.isHidden = false
            enableTxtField(enabled: true)
        }
        
    }

}
