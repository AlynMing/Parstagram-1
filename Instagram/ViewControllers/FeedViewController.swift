//
//  FeedViewController.swift
//  Instagram
//
//  Created by Mina Kim on 10/17/20.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var numPosts = 20
    var showsCommentBar = false
    var selectedPost : PFObject!
    
    let defaults = UserDefaults.standard
    let commentBar = MessageInputBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        //Bind refreshControl to action
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        //Bind control to tableView
        tableView.refreshControl = refreshControl
        
        //Edit commentBar button features
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.keyboardDismissMode = .interactive
        
        //Adds hideKeyboard() method to notification center
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(hideKeyboard(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        retrievePosts()
    }
    
    func retrievePosts(){
        let query = PFQuery(className: "Posts")
        query.includeKeys(["user", "comments", "comments.author"])
        query.limit = numPosts
        
        query.findObjectsInBackground {(posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                print("Could not find posts: \(error)")
            }
        }
    }
    
    //Used to format commentBar
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    @objc func hideKeyboard(note: Notification){
        commentBar.inputTextView.text = ""
        showsCommentBar = false
        becomeFirstResponder() //Runs canBecomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Creates comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["user"] = PFUser.current()!

        //Adds Comment objects to post
        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Saved comment")
            } else {
                print("Failed to save comment: \(error)")
            }
        }
        tableView.reloadData()
     
        //Dismiss commentBar
        commentBar.inputTextView.text = ""
        showsCommentBar = false
        becomeFirstResponder() //Runs canBecomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCell
            
            let user = post["user"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            //Retrieves image url/data
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
            
            //Set comment body
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as! String
            //Set usernameLabel
            let user = post["user"] as! PFUser
            cell.usernameLabel.text = user.username
            
            return cell
        } else {
            //Return "Add Comment..." cell of table view
            return tableView.dequeueReusableCell(withIdentifier: "addCommentCell")!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder() //Runs canBecomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    //Not working
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == posts.count{
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
//                self.numPosts += 20
//                self.retrievePosts()
//            }
//        }
//    }

    @IBAction func didTapLogout(_ sender: Any) {
        defaults.setValue(false, forKey: "loggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        retrievePosts()
        refreshControl.endRefreshing()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
