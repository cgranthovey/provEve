//
//  MilesVC.swift
//  Ibento
//
//  Created by Chris Hovey on 11/4/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol MilesChosen {
    func numberOfMiles(miles: Int)
}

class MilesVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!

    var delegate: MilesChosen!
    var rowSelected = 0
    var milesPreviouslyChosen: Int?
    var arrayOfMilesString = ["3 miles", "5 miles", "10 miles", "15 miles", "25 miles", "50 miles", "100 miles", "150 miles"]
    var arrayOfMiles = [3, 5, 10, 15, 25, 50, 100, 150]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        self.view.backgroundColor = UIColor().boilerPlateColor(0, green: 0, blue: 0, alpha: 0.75)
        
        setUpPickerViewPreset()
    }
    
    func setUpPickerViewPreset(){
        let pres = NSUserDefaults.standardUserDefaults()
        if let miles = pres.objectForKey(Constants.instance.nsUserDefaultsKeySettingsMiles){
            let milesInt = miles.integerValue
            if let index = arrayOfMiles.indexOf(milesInt){
                let a = arrayOfMiles.startIndex.distanceTo(index)
                pickerView.selectRow(a, inComponent: 0, animated: false)
            }
        } else{
            pickerView.selectRow(5, inComponent: 0, animated: false)
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfMilesString[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rowSelected = row
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfMiles.count
    }

    @IBAction func set(sender: AnyObject){
        let miles = arrayOfMiles[rowSelected]
        delegate.numberOfMiles(miles)
        NSNotificationCenter.defaultCenter().postNotificationName("loadDataAfterNewEvent", object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancel(sender:AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
