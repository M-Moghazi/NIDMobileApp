//
//  FeedsTableViewController.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 4/22/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import UIKit
import Parse

class FeedsTableViewController: UITableViewController {
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    var titleArray = [String]()
    var bodyArray = [String]()
    var postDateArray = [NSDate]()
    var postIdArray = [PFObject]()
    var PFUserArray = [PFUser]()
    
    var pageLimit = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPosts()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerForPushNotifications()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedsTableViewController.refresher), name: NSNotification.Name(rawValue: "like"), object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 580
        
        tableView.separatorStyle = .none

        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor(colorLiteralRed: 0/255, green: 121/255, blue: 193/255, alpha: 1)
        refreshControl?.addTarget(self, action: #selector(FeedsTableViewController.refresh), for: UIControlEvents.valueChanged)
    }

    func refresh () {
        loadPosts()
    }
    func refresher() {
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadPosts()
    }
    
    func loadPosts() {
        let postsQuery = PFQuery(className: "Posts")
        postsQuery.addDescendingOrder("createdAt")
        postsQuery.limit = pageLimit
        postsQuery.includeKey("author")
        postsQuery.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if error == nil {
                
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                self.bodyArray.removeAll(keepingCapacity: false)
                self.postDateArray.removeAll(keepingCapacity: false)
                
                self.PFUserArray.removeAll(keepingCapacity: false)
                
                for post in posts! {
                    self.postIdArray.append(post)
                    self.uuidArray.append(post.value(forKey: "uuid") as! String)
                    self.picArray.append(post.value(forKey: "pic") as! PFFile)
                    self.titleArray.append(post.value(forKey: "title") as! String)
                    self.bodyArray.append(post.value(forKey: "body") as! String)
                    self.postDateArray.append(post.createdAt! as NSDate)
                    
                    let authorObj = post.object(forKey: "author") as! PFUser
                    self.PFUserArray.append(authorObj)
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            } else {
                self.refreshControl?.endRefreshing()
                print(error!.localizedDescription)
            }
            
        }
    }
    


    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 1.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 1.0 {
            loadmore()
        }
    }
    
    func loadmore() {
        if pageLimit <= uuidArray.count {
            self.pageLimit += 5
            loadPosts()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuidArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostTableViewCell

        cell.uuid.text = uuidArray[indexPath.row]
        cell.postTitleLbl.text = titleArray[indexPath.row]
        cell.postBody.text = bodyArray[indexPath.row]
        
        cell.postTitleLbl.sizeToFit()
        cell.postBody.sizeToFit()
        
        cell.authorName.text = PFUserArray[indexPath.row].object(forKey: "fullName") as? String
        cell.authorJobTitle.text = PFUserArray[indexPath.row].object(forKey: "jobTitle") as? String
        
        let authorAvatar = PFUserArray[indexPath.row].object(forKey: "avatar") as! PFFile
        authorAvatar.getDataInBackground { (data: Data?, error: Error?) in
            cell.authorAvatar.image = UIImage(data: data!)
        }

        picArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.pic.image = UIImage(data: data!)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        let postDate = postDateArray[indexPath.row]
        let date = dateFormatter.string(from: postDate as Date)
        cell.postDate.text = date
        
        let didLiked = PFQuery(className: "Likes")
        didLiked.whereKey("by", equalTo: PFUser.current()!.username!)
        didLiked.whereKey("to", equalTo: cell.uuid.text!)
        didLiked.countObjectsInBackground { (count: Int32, error: Error?) in
            if count == 0 {
                cell.likeBtnLbl.setTitle("unlike", for: .normal)
                cell.likeBtnLbl.setBackgroundImage(#imageLiteral(resourceName: "unlike.png"), for: .normal)
            } else {
                cell.likeBtnLbl.setTitle("like", for: .normal)
                cell.likeBtnLbl.setBackgroundImage(#imageLiteral(resourceName: "like.png"), for: .normal)
            }
        }
        
        let likesCount = PFQuery(className: "Likes")
        likesCount.whereKey("to", equalTo: cell.uuid.text!)
        likesCount.countObjectsInBackground { (count: Int32, error: Error?) in
            if count == 0 {
                cell.likesCountLbl.text = ""
            } else {
                cell.likesCountLbl.text = "\(count)"
            }
        }
        
        if PFUserArray[indexPath.row].object(forKey: "username") as? String == PFUser.current()?.username {
            cell.editBtnLbl.isHidden = false
        }
        
        let commentCount = PFQuery(className: "Comments")
        commentCount.whereKey("to", equalTo: cell.uuid.text!)
        commentCount.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                if count > 0 {
                    cell.commentCountLbl.text = "\(count)"
                } else {
                    cell.commentCountLbl.text = ""
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        return cell

    }

    @IBAction func commentBtn(_ sender: Any) {
        let i = (sender as AnyObject).layer.value(forKey: "index")
        let cell = tableView.cellForRow(at: i as! IndexPath) as! PostTableViewCell

        commentuuid.append(cell.uuid.text!)
        commentowner.append(cell.authorName.text!)
        postId.append(postIdArray[(i as! IndexPath).row])
        
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentsViewController
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    
    @IBAction func editBtn(_ sender: Any) {
        
        let deleteAlert = UIAlertController(title: "Delete Post", message: "Do you want to delete post forever", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "delete", style: .destructive) { (action) in
            
            let buttonPosition : CGPoint = (sender as AnyObject).convert((sender as AnyObject).bounds.origin, to: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: buttonPosition)!


            //delete post from server
            let postQuery = PFQuery(className: "Posts")
            postQuery.whereKey("uuid", equalTo: self.uuidArray[indexPath.row])
            postQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            //delete posts' comments from server
            let commentsQuery = PFQuery(className: "Comments")
            commentsQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
            commentsQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            //delete posts' likes from server
            let likesQuery = PFQuery(className: "Likes")
            likesQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
            likesQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            //update arrays
            self.uuidArray.remove(at: indexPath.row)
            self.picArray.remove(at: indexPath.row)
            self.titleArray.remove(at: indexPath.row)
            self.bodyArray.remove(at: indexPath.row)
            self.postDateArray.remove(at: indexPath.row)
            self.PFUserArray.remove(at: indexPath.row)
            
            //delete from table
            self.tableView.deleteRows(at: [indexPath] , with: .automatic)
            
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        self.present(deleteAlert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        
        PDTitle = cell.postTitleLbl.text!
        PDAuthor = cell.authorName.text!
        PDAuthorPic = cell.authorAvatar.image!
        PDJob = cell.authorJobTitle.text!
        PDDate = cell.postDate.text!
        PDimage = cell.pic.image!
        PDBody = cell.postBody.text!
        
        PDcommentuuid.append(cell.uuid.text!)
        PDcommentowner.append(cell.authorName.text!)
        
        
        let PostDetail = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailVC") as! PostDetailViewController
        self.navigationController?.pushViewController(PostDetail, animated: true)
    }
    
}
