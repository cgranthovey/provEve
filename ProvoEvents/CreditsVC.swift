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
        print("View did load")
        tableView.delegate = self
        tableView.dataSource = self
        
        setUpArray()
    }
    
    func setUpArray(){
        let attString = NSMutableAttributedString(string: "Gregor Črešnar from The Noun Project")
        attString.addAttribute(NSLinkAttributeName, value: "https://thenounproject.com/", range: NSRange(location: 20, length: 16))
        
        let credit = Credit(lbl: attString, imageStr: "textMessage")
        
        let attString2 = NSMutableAttributedString(string: "Tom Walsh from The Noun Project")
        attString2.addAttribute(NSLinkAttributeName, value: "https://thenounproject.com/", range: NSRange(location: 15, length: 16))
        
        let credit2 = Credit(lbl: attString2, imageStr: "worldFull")

        let attString4 = NSMutableAttributedString(string: "Martin Chapman Fromm from The Noun Project")
        attString4.addAttribute(NSLinkAttributeName, value: "https://thenounproject.com/", range: NSRange(location: 26, length: 16))
        
        let credit4 = Credit(lbl: attString4, imageStr: "pinIcon")
        
        creditsArray = [credit, credit2, credit4]
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? creditsCell{
            cell.configureCell(creditsArray[indexPath.row])
            return cell
        }
        print("outside")
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count \(creditsArray.count)")
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