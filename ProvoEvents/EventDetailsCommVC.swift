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
        
        NotificationCenter.default.addObserver(self, selector: #selector(EventDetailsCommVC.deleteComment(_:)), name: NSNotification.Name(rawValue: "commentDelete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EventDetailsCommVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(EventDetailsCommVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        initiateAlphaBgView()
        getComments()
        setUpGestureRecs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "commentDelete"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swiftLeft = UISwipeGestureRecognizer(target: self, action: #selector(EventDetailsCommVC.swipeLeft1))
        swiftLeft.direction = .left
        view.addGestureRecognizer(swiftLeft)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsCommVC.tapToDismiss))
        view.addGestureRecognizer(tap)
    }
    
    func initiateAlphaBgView(){
        alphaBackgroundView.alpha = 0
        alphaBackgroundView.backgroundColor = UIColor.black
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseOut, animations: { 
            self.alphaBackgroundView.alpha = 0.7
            }, completion: nil)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Delete Comments
    
    func deleteComment(_ notif: Notification){
        if let commentKey = notif.object as? String{
            deleteCommentKey = commentKey
            deleteLauncher.showDeleteView(self.view, lblText: "Delete Comment?")

        }
    }

    func yesPressed() {
        if let i = self.commentArray.index(where: {$0.key == self.deleteCommentKey}){
            DataService.instance.commentRef.child(self.event.key).child(self.deleteCommentKey).removeValue()
            DataService.instance.currentUser.child("comments").child(self.event.key).child(self.deleteCommentKey).removeValue()
            let indexPath = IndexPath(row: i, section: 0)
            self.commentArray.remove(at: i)
            self.commentsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Keyboard

    func tapToDismiss(){
        self.view.endEditing(true)
    }
    
    func keyboardWillHide(_ sender: Notification) {
        keyboardUp = false
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        self.bottomShadowView.constant = self.bottomShadowView.constant - keyboardSize.height
        self.view.layoutIfNeeded()
    }

    func keyboardWillShow(_ sender: Notification) {

            let userInfo: [AnyHashable: Any] = sender.userInfo!
            let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
            let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
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
    
    func animateCommentsOut(_ amount: CGFloat){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.endEditing(true)
            self.shadowView.frame.origin.x = self.view.frame.origin.x + amount
        }, completion: { (true) in
            UIView.animate(withDuration: 0.25, animations: {
                self.alphaBackgroundView.alpha = 0
                }, completion: { (true) in
                    self.view.alpha = 0
                    self.dismiss(animated: false, completion: nil)
            })
        }) 
    }

    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //Submit Comments
    
    @IBAction func postTouchDown(_ sender: AnyObject) {
        postBtn.backgroundColor = UIColor().boilerPlateColor(173, green: 20, blue: 87)
    }
    
    @IBAction func postTouchUpOutside(_ sender: AnyObject) {
        postBtn.backgroundColor = UIColor().boilerPlateColor(233, green: 30, blue: 99)
    }
    
    @IBAction func submitComment(_ sender: UITextView){
        let date = Date()
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
            let setComment: Dictionary<String, AnyObject> = ["userId": (FIRAuth.auth()?.currentUser?.uid)! as AnyObject, "comment": commentTextView.text as AnyObject, "timeStamp": timeIntervalSince1970 as AnyObject]
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
        DataService.instance.commentRef.child(event.key).observeSingleEvent(of: .value, with: { snapshot in
            print("are none")
            if snapshot.value is NSNull{
                print("there are none")
                self.showNoCommentsLbl()
            }
            
        })
        
        DataService.instance.commentRef.child(event.key).observe(.childAdded, with: { snapshot in
            print("mom")
            
            if let snap = snapshot.value as? Dictionary<String, AnyObject>{
                let comment = Comment(dict: snap, key: snapshot.key)
                print("there are comments")
                
                DataService.instance.userRef.child(comment.userId!).child("profile").child("userName").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let name = snapshot.value as? String{
                        comment.userName = name
                    }
                    self.commentArray.insert(comment, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.commentsTableView.insertRows(at: [indexPath], with: .automatic)
                })
            }
        })
        
        DataService.instance.commentRef.child(event.key).observe(.childRemoved, with: { snapshot in
            if let index = self.indexOfSnap(snapshot){
                self.commentArray.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.commentsTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        })
    }
    
    func showNoCommentsLbl(){
        let noDataLbl: UILabel = UILabel(frame: CGRect(x: 20, y: 40, width: 200, height: 40))
        noDataLbl.numberOfLines = 10
        noDataLbl.text = "Post the first comment"
        noDataLbl.font = UIFont(name: "Avenir", size: 20)
        noDataLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
        noDataLbl.textAlignment = .center
        commentsTableView.backgroundView = noDataLbl
    }

    func indexOfSnap(_ snapshot: FIRDataSnapshot) -> Int?{
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as? CommentsCell{
            cell.configureCell(commentArray[indexPath.row])
            return cell
        } else{
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSection = 0
        if commentArray.count > 0{
            numberOfSection = 1
            tableView.backgroundView = nil
        } else{
            
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
}







