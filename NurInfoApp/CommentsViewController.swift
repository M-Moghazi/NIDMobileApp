//
//  CommentsViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/24/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentowner = [String]()
var postId = [PFObject]()

class CommentsViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var commentBtnLbl: UIButton!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtnLbl: UIButton!
    @IBOutlet weak var noCommentLbl: UITextView!

    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    var commenterArray = [PFUser]()
    var commentArray = [String]()
    var dateArray = [NSDate]()

    var refresh = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        tableView.tableFooterView = UIView()
        
        commentTxt.layer.cornerRadius = 5
        
        tableView.delegate = self
        tableView.dataSource = self
        
        commentTxt.delegate = self
        if commentTxt.text.isEmpty {
            sendBtnLbl.isEnabled = false
        }
        
        self.navigationItem.title = "Comments"
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (CommentsViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        if !commentowner.isEmpty {
            commentowner.removeLast()
        }
    }
    @IBAction func sendBtn(_ sender: Any) {
        
        // update table with comments
        dateArray.append(NSDate())
        commentArray.append(commentTxt.text.trimmingCharacters(in: .whitespacesAndNewlines))
        commenterArray.append(PFUser.current()!)
        tableView.reloadData()
        
        // Send comment to server
        let commentObj = PFObject(className: "Comments")
        commentObj["to"] = commentuuid.last
        commentObj["comment"] = commentTxt.text.trimmingCharacters(in: .whitespacesAndNewlines)
        commentObj["from"] = PFUser.current()!
        commentObj["post"] = postId.last!
        
        commentObj.saveEventually()
        
        //reset UI
        commentTxt.text = ""
        commentTxt.resignFirstResponder()
        sendBtnLbl.isEnabled = false
        self.bottomConstrain.constant = 8
        UIView.animate(withDuration: 0.25, animations: {
            () -> Void in self.view.layoutIfNeeded()
        })
        
        if commentArray.count != 0 {
            self.noCommentLbl.isHidden = true
        }
        
        scrollToBottom()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let spaces = NSCharacterSet.whitespacesAndNewlines
        if textView == commentTxt {
            self.sendBtnLbl.isEnabled = !commentTxt.text.trimmingCharacters(in: spaces).isEmpty
        }
        
        if commentTxt.contentSize.height < 100 && !commentTxt.text.isEmpty {
            let difference = commentTxt.contentSize.height - commentTxt.frame.size.height
            commentTxt.frame.origin.y -= difference
            tableView.frame.size.height -= difference
            commentTxt.frame.size.height = commentTxt.contentSize.height
        } else if commentTxt.contentSize.height >= 100 {
            commentTxt.frame.size.height = 98
        }
    }
    
    //TODO: Make the textview dismiss if contain more than 1 line
    func hideKeyboard() {
        if commentTxt.frame.height < 40 {
            view.endEditing(true)
            self.bottomConstrain.constant = 8
            UIView.animate(withDuration: 0.25, animations: {
                () -> Void in self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            
            if commentTxt.contentSize.height < 100 && !commentTxt.text.isEmpty {
                let difference = commentTxt.contentSize.height - commentTxt.frame.size.height
                commentTxt.frame.origin.y -= difference
                tableView.frame.size.height -= difference
                commentTxt.frame.size.height = commentTxt.contentSize.height
            } else if commentTxt.contentSize.height >= 100 {
                commentTxt.frame.size.height = 98
                commentTxt.frame.origin.y = view.frame.size.height - keyboardSize.height -  108
            }

            self.bottomConstrain.constant = keyboardSize.height + 8
            UIView.animate(withDuration: 0.25, animations: {
                () -> Void in self.view.layoutIfNeeded()
            })
            
            self.scrollToBottom()
        }
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentCell
        
        cell.fullnameLbl.text = commenterArray[indexPath.row].object(forKey: "fullName") as? String
        
        let commenterAvatar = commenterArray[indexPath.row].object(forKey: "avatar") as! PFFile
        commenterAvatar.getDataInBackground { (data: Data?, error: Error?) in
            cell.avatar.image = UIImage(data: data!)
        }
        
        cell.commentLbl.text = commentArray[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        let commentDate = dateArray[indexPath.row]
        let date = dateFormatter.string(from: commentDate as Date)
        cell.commentDate.text = date
        
        
        return cell
    }
    
    //load comments
    func loadData() {
        let query = PFQuery(className: "Comments")
        //query.whereKey("to", equalTo: commentuuid.last!)
        query.whereKey("post", equalTo: postId.last!)
        query.includeKey("from")
        query.addAscendingOrder("createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                
                self.commentArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.commenterArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.commentArray.append(object.object(forKey: "comment") as! String)
                    self.dateArray.append(object.createdAt! as NSDate)
                    
                    let commenterObj = object.object(forKey: "from") as! PFUser
                    self.commenterArray.append(commenterObj)
                    
                    self.tableView.reloadData()
                }
                
                self.scrollToBottom()
                
                if self.commentArray.count == 0 {
                    self.noCommentLbl.isHidden = false
                } else {
                    self.noCommentLbl.isHidden = true
                }
                
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    //scroll table to bottom
    func scrollToBottom() {
        if self.commentArray.count != 0 {
            let lastCellIndexPath = IndexPath(row: self.commentArray.count - 1, section: 0)
            self.tableView.scrollToRow(at: lastCellIndexPath, at: .bottom, animated: true)
        }
    }
    
    //swipe to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if commenterArray[indexPath.row].objectId == PFUser.current()?.objectId {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            //delete from server
            let query = PFQuery(className: "Comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.whereKey("comment", equalTo: commentArray[indexPath.row])
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            //update arrays
            commentArray.remove(at: indexPath.row)
            commenterArray.remove(at: indexPath.row)
            dateArray.remove(at: indexPath.row)
            
            //remove row from tableview
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if commentArray.count == 0 {
                self.noCommentLbl.isHidden = false
            }
        }
    }
    
}
