//
//  CreditsVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/31/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class CreditsVC: GeneralVC, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var str1 = NSMutableAttributedString()
    var creditsArray = [Credit]()
    var creditsImages = ["textMessage", "threeLines"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUpArray()
    }
    
    func setUpArray(){
        makeFlatIconCredit("Gregor Črešnar from The Noun Project", imgString: "textMessage", url: "https://thenounproject.com/grega.cresnar/", urlWebsite: "https://thenounproject.com/")
        makeFlatIconCredit("Tom Walsh from The Noun Project", imgString: "worldFull", url: "https://thenounproject.com/tomwalshdesign/", urlWebsite: "https://thenounproject.com/")
        makeFlatIconCredit("Martin Chapman Fromm from The Noun Project", imgString: "pinIcon", url: "https://thenounproject.com/martincf/", urlWebsite: "https://thenounproject.com/")
        madeByOliver("addEvent")
        makeFlatIconCredit("Darius Dan from www.flaticon.com", imgString: "backBlack", url: "http://swifticons.com/")
        makeFlatIconCredit("Metropolicons from www.flaticon.com", imgString: "calendarClear", url: "https://metropolicons.com/")
        madeByFreePik("checkMap")
        madeByFreePik("checkmark")
        madeByFreePik("coordinates")
        madeByFreePik("delete")
        madeByOliver("Download")
        madeByFreePik("art")
        madeByFreePik("book")
        madeByFreePik("dance")
        madeByOliver("football")
        madeByOliver("music")
        madeByOliver("outdoors")
        madeByOliver("prayer")
        madeByOliver("sandwich")
        madeByFreePik("service")
        madeByFreePik("theater")
        madeByOliver("garbage")
        makeFlatIconCredit("Vectors Market from www.flaticon.com", imgString: "geoMarker", url: "http://www.flaticon.com/authors/vectors-market")
        madeByFreePik("heartFilled")
        madeByOliver("lock")
        makeFlatIconCredit("Iconnice from www.flaticon.com", imgString: "mail", url: "http://www.iconnice.com/")    //required
        madeByOliver("photoAlbumColor")
        madeByFreePik("profile")
        makeFlatIconCredit("Roundicons from www.flaticon.com", imgString: "questionMap", url: "https://roundicons.com/")
        madeByOliver("settings")
        makeFlatIconCredit("Vectors Market from www.flaticon.com", imgString: "target2", url: "http://www.flaticon.com/authors/vectors-market")
        makeFlatIconCredit("Revicon from www.flaticon.com", imgString: "threeLines", url: "http://www.flaticon.com/authors/revicon")
        madeByOliver("thumbsUp")
        madeByFreePik("cloud")
        madeByFreePik("moon")
        madeByFreePik("rain")
        madeByFreePik("snow")
        madeByFreePik("sun")
        madeByFreePik("thunder")
        madeByOliver("worldGrid")
        madeByOliver("lockColor")
        makeFlatIconCredit("Pixel Buddha from www.flaticon.com", imgString: "wifi", url: "http://www.flaticon.com/authors/pixel-buddha")
        madeByFreePik("grass")
        madeByOliver("mailColor")
        madeByOliver("mailbox")
        makeFlatIconCredit("Y from The Noun Project", imgString: "foxIcon", url: "https://thenounproject.com/y3816627/", urlWebsite: "https://thenounproject.com/")
        makeFlatIconCredit("Yannick from www.flaticon.com", imgString: "swipeRight", url: "http://www.flaticon.com/authors/yannick")
        makeFlatIconCredit("Yannick from www.flaticon.com", imgString: "swipeLeft", url: "http://www.flaticon.com/authors/yannick")
    }
    
    func madeByFreePik (image: String){
        makeFlatIconCredit("Freepik from www.flaticon.com", imgString: image, url: "http://www.freepik.com/")
    }
    
    func madeByOliver(image: String){
        makeFlatIconCredit("Madebyoliver from www.flaticon.com", imgString: image, url: "http://www.flaticon.com/authors/madebyoliver")
    }
    
    func makeFlatIconCredit(strTotal: String, imgString: String, url: String, urlWebsite: String = "http://www.flaticon.com/"){
        let indexOfFrom = (strTotal.indexOf("from "))
        let intValueOfFrom = strTotal.startIndex.distanceTo(indexOfFrom!)
        let count =  intValueOfFrom - 1
        print("Int  valueof from  \(intValueOfFrom)")
        let urlWebsiteCount = urlWebsite.characters.count
        let attString = NSMutableAttributedString(string: strTotal)
        attString.addAttribute(NSLinkAttributeName, value: url, range: NSRange(location: 0, length: count))

        if urlWebsite != ""{
            var beginingOfWebsite = count + 6
            attString.addAttribute(NSLinkAttributeName, value: urlWebsite, range:  NSRange(location: beginingOfWebsite, length: strTotal.characters.count - beginingOfWebsite))
        }
        let credit = Credit(lbl: attString, imageStr: imgString)
        creditsArray.append(credit)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //tableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? creditsCell{
            cell.configureCell(creditsArray[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        UIApplication.sharedApplication().openURL(URL)
        return false
    }
    
    @IBAction func popBack(sender: AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
}