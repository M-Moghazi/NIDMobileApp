//
//  SettingTableViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/20/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var fullNameTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatar.layer.borderColor = UIColor.init(colorLiteralRed: 239/255, green: 239/255, blue: 244/255, alpha: 1.0).cgColor
        avatar.layer.borderWidth = 1    
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.clipsToBounds = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() != nil {
            usernameLbl.text! = PFUser.current()?.object(forKey: "username") as! String
            fullNameTxt.text! = PFUser.current()?.object(forKey: "fullName") as! String
            
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = "Cancel"
        navigationItem.backBarButtonItem = backButton
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return 4
        } else {
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func logOutBtn(_ sender: Any) {
        view.isUserInteractionEnabled = false
        view.layer.opacity = 0.5
        PFUser.logOutInBackground()
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.synchronize()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignIn")
        self.present(vc!, animated: true, completion: nil)
        view.isUserInteractionEnabled = true
        view.layer.opacity = 1
    }
    

}
