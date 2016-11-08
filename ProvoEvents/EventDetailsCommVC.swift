//
//  EventDetailsCommVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/13/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EventDetailsCommVC: GeneralVC, UITextViewDelegate, yesSelectedProtocol{

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet var bottomShadowView: NSLayoutConstraint!
    @IBOutlet weak var alphaBackgroundView: UIView!
    @IBOutlet weak var postBtn: UIButton!

    var event: Event!
    var commentArray = [Comment]()
    var deleteLauncher = yesNoLauncher()
    var keyboardUp = false
    var keyboardHeight: CGFloat!
    var deleteCommentKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteLauncher.delegate = self
        eventTitle.text = event.title
        setUpCommentTB()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventDetailsCommVC.deleteComment(_:)), name: "commentDelete", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventDetailsCommVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventDetailsCommVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        
        initiateAlphaBgView()
        getComments()
        setUpGestureRecs()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "commentDelete", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        self.view.endEditing(true)
        if let height = keyboardHeight{
            self.bottomShadowView.constant = self.bottomShadowView.constant - height
            self.view.layoutIfNeeded()
        }
    }
    
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //SetUp UI
    
    func setUpCommentTB(){
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.estimatedRowHeight = 40
        commentsTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        commentTextView.delegate = self
    }
    
    func setUpGestureRecs(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(EventDetailsCommVC.swipeRight1))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(EventDetailsCommVC.swipeLeft1))
        swiftLeft.direction = .Left
        view.addGestureRecognizer(swiftLeft)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsCommVC.tapToDismiss))
        view.addGestureRecognizer(tap)
    }
    
    func initiateAlphaBgView(){
        alphaBackgroundView.alpha = 0
        alphaBackgroundView.backgroundColor = UIColor.blackColor()
        UIView.animateWithDuration(0.25, delay: 0.25, options: .CurveEaseOut, animations: { 
            self.alphaBackgroundView.alpha = 0.7
            }, completion: nil)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Delete Comments
    
    func deleteComment(notif: NSNotification){
        if let commentKey = notif.object as? String{
            deleteCommentKey = commentKey
            deleteLauncher.showDeleteView(self.view, lblText: "Delete Comment?")

        }
    }

    func yesPressed() {
        if let i = self.commentArray.indexOf({$0.key == self.deleteCommentKey}){
            DataService.instance.commentRef.child(self.event.key).child(self.deleteCommentKey).removeValue()
            DataService.instance.currentUser.child("comments").child(self.event.key).child(self.deleteCommentKey).removeValue()
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            self.commentArray.removeAtIndex(i)
            self.commentsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Keyboard

    func tapToDismiss(){
        self.view.endEditing(true)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        keyboardUp = false
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.bottomShadowView.constant = self.bottomShadowView.constant - keyboardSize.height
        self.view.layoutIfNeeded()
    }

    func keyboardWillShow(sender: NSNotification) {

            let userInfo: [NSObject : AnyObject] = sender.userInfo!
            let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
            let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
            keyboardHeight = keyboardSize.height

            if !keyboardUp{
                keyboardUp = true
                if keyboardSize.height == offset.height {
                    self.bottomShadowView.constant = self.bottomShadowView.constant + keyboardSize.height
                    self.view.layoutIfNeeded()

                } else {
                    self.bottomShadowView.constant += keyboardSize.height - offset.height
                    self.view.layoutIfNeeded()
                }
            } else{
                if keyboardHeight != offset.height{
                    self.bottomShadowView.constant = self.bottomShadowView.constant + offset.height - self.keyboardHeight
                }
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Dismiss VC
    
    func swipeLeft1(){
        animateCommentsOut(-self.view.frame.width)
    }
    
    func swipeRight1(){
        animateCommentsOut(self.view.frame.width)
    }
    
    func animateCommentsOut(amount: CGFloat){
        UIView.animateWithDuration(0.25, animations: {
            self.view.endEditing(true)
            self.shadowView.frame.origin.x = self.view.frame.origin.x + amount
        }) { (true) in
            UIView.animateWithDuration(0.25, animations: {
                self.alphaBackgroundView.alpha = 0
                }, completion: { (true) in
                    self.view.alpha = 0
                    self.dismissViewControllerAnimated(false, completion: nil)
            })
        }
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Submit Comments
    
    @IBAction func postTouchDown(sender: AnyObject) {
        postBtn.backgroundColor = UIColor().boilerPlateColor(173, green: 20, blue: 87)
    }
    
    @IBAction func postTouchUpOutside(sender: AnyObject) {
        postBtn.backgroundColor = UIColor().boilerPlateColor(233, green: 30, blue: 99)
    }
    
    @IBAction func submitComment(sender: UITextView){
        let date = NSDate()
        let timeIntervalSince1970 = Int(date.timeIntervalSince1970)
        
        let key = DataService.instance.commentRef.child(event.key).childByAutoId().key
        postBtn.backgroundColor = UIColor().boilerPlateColor(233, green: 30, blue: 99)

        var numberOfRows: CGFloat = 0
        if let rows: CGFloat = round( (commentTextView.contentSize.height - commentTextView.textContainerInset.top - commentTextView.textContainerInset.bottom) / commentTextView.font!.lineHeight){
            numberOfRows = rows
        }
        
        if commentTextView.text == nil || commentTextView.text == ""{
            generalAlert("Error", message: "The comment field is not filled out")
        } else if numberOfRows > 25{
            generalAlert("Error", message: "Comments can not be more than 25 lines")
        } else {
            print(FIRAuth.auth()?.currentUser?.uid)
            let setComment: Dictionary<String, AnyObject> = ["userId": (FIRAuth.auth()?.currentUser?.uid)!, "comment": commentTextView.text, "timeStamp": timeIntervalSince1970]
            DataService.instance.commentRef.child(event.key).child(key).setValue(setComment)
            DataService.instance.currentUser.child("comments").child(event.key).child(key).setValue("True")
            // can use .updateChildValues to look for error if desired

            commentTextView.text = ""
            self.view.endEditing(true)
        }
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Receive Comments, Add/Remove
    
    func getComments(){
        DataService.instance.commentRef.child(event.key).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("are none")
            if snapshot.value is NSNull{
                print("there are none")
                self.showNoCommentsLbl()
            }
            
        })
        
        DataService.instance.commentRef.child(event.key).observeEventType(.ChildAdded, withBlock: { snapshot in
            print("mom")
            
            if let snap = snapshot.value as? Dictionary<String, AnyObject>{
                let comment = Comment(dict: snap, key: snapshot.key)
                print("there are comments")
                
                DataService.instance.userRef.child(comment.userId!).child("profile").child("userName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    if let name = snapshot.value as? String{
                        comment.userName = name
                    }
                    self.commentArray.insert(comment, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.commentsTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                })
            }
        })
        
        DataService.instance.commentRef.child(event.key).observeEventType(.ChildRemoved, withBlock: { snapshot in
            if let index = self.indexOfSnap(snapshot){
                self.commentArray.removeAtIndex(index)
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.commentsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        })
    }
    
    func showNoCommentsLbl(){
        let noDataLbl: UILabel = UILabel(frame: CGRectMake(20, 40, 200, 40))
        noDataLbl.numberOfLines = 10
        noDataLbl.text = "Post the first comment"
        noDataLbl.font = UIFont(name: "Avenir", size: 20)
        noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
        noDataLbl.textAlignment = .Center
        commentsTableView.backgroundView = noDataLbl
    }

    func indexOfSnap(snapshot: FIRDataSnapshot) -> Int?{
        if let snap = snapshot.value as? Dictionary<String, AnyObject>{
            let comment = Comment(dict: snap, key: snapshot.key)
            var x = 0
            for commentCompare in commentArray{
                if comment.key == commentCompare.key{
                    return x
                }
                x = x + 1
            }
        }
        return nil
    }
}

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//Table View Extension

extension EventDetailsCommVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("commentsCell") as? CommentsCell{
            cell.configureCell(commentArray[indexPath.row])
            return cell
        } else{
            return UITableViewCell()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfSection = 0
        if commentArray.count > 0{
            numberOfSection = 1
            tableView.backgroundView = nil
        } else{
            
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
}







