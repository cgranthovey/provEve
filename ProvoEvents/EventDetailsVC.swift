//
//  EventDetailsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/22/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class EventDetailsVC: GeneralVC {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLoc: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var email: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var event: Event!
    var img: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        
        eventImg.userInteractionEnabled = true
        var tap = UITapGestureRecognizer(target: self, action: #selector(EventDetailsVC.toLargeImg))
        eventImg.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize.height = stackView.frame.height + 110

    }
    
    func toLargeImg(){
        if img != nil{
            performSegueWithIdentifier("ImageLargeVC", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ImageLargeVC"{
            if let destVC = segue.destinationViewController as? ImageLargeVC{
                destVC.img = img
            }
        }
    }
    
    
    
    @IBAction func toMailVC(){
        
    }
    
    func setUpUI(){
        eventTitle.text = event.title
        eventDescription.text = event.description
        eventLoc.text = event.location
        eventDate.text = event.date
        
        


        
        if let holdEmail = event.email{
        }else{
            email.hidden = true
        }
        
        if let holdEventImg = event.imgURL{
            ImgCacheLoader.sharedLoader.imageForUrl(holdEventImg) { (image, url) in
                self.img = image
                self.eventImg.image = self.img!
                self.eventImg.roundCornersForAspectFit(5)
            }
        }else{
            eventImg.hidden = true
        }
    }

}
