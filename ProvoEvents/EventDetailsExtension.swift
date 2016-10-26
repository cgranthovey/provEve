//
//  AddEventExtenstion.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation


extension EventDetailsVC{
    
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//Get weather info 
    
    func callWeather(eventTime: Int){
        var eventWeatherDict: Dictionary<String, AnyObject>!
        
        let longitudeRounded =  Double(round(1000 * event.pinInfoLongitude!) / 1000)
        let longitudeString = String(longitudeRounded)
        print("longString \(longitudeString)")
        
        let latitudeRounded = Double(round(1000 * event.pinInfoLatitude!) / 1000)
        let latidudeString = String(latitudeRounded)
        print("latString \(latidudeString)")
        
        let endPoint: String = "http://api.openweathermap.org/data/2.5/forecast?APPID=e8535c81703fe79f0f17726667bc0c27&lat=\(latidudeString)&lon=\(longitudeString)"
        let url = NSURL(string: endPoint)!
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            do {
                
                guard let realResponse = response as? NSHTTPURLResponse where realResponse.statusCode == 200 else{
                    print("not a 200 response")
                    return
                }
                
                if let ipString = NSString(data: data!, encoding: NSUTF8StringEncoding){
                    let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if let threeHourArray = jsonDict["list"] as? [Dictionary<String, AnyObject>]{
                        for three in threeHourArray{
                            if let threeTime = three["dt"] as? Int{
                                if eventTime <= threeTime{
                                    
                                    print(three)
                                    
                                    eventWeatherDict = three
                                    print("What")
                                    if let main = eventWeatherDict["main"] as? Dictionary<String, AnyObject>, weatherArray = eventWeatherDict["weather"] as? [Dictionary<String, AnyObject>]{
                                        print("The")
                                        
                                        if let weatherDesc = weatherArray[0] as? Dictionary<String, AnyObject>{
                                            print("heck")
                                            
                                            print(main["temp"])
                                            print(eventWeatherDict["dt_txt"])
                                            print(weatherDesc["description"])
                                            print(weatherDesc["id"])
                                            

                                            
                                            if let eventTemp = main["temp"] as? Double, dateText = eventWeatherDict["dt_txt"], eventWeatherDesc = weatherDesc["description"] as? String, weatherID = weatherDesc["id"] as? Int{
                                                print("eventWeatherTemp \(eventTemp) eventWeatherDesc \(eventWeatherDesc)")
                                                
                                                let tempStringFahrenheit = self.kelvinToCelcius(eventTemp)

                                                dispatch_async(dispatch_get_main_queue()){
                                                    self.weatherTemp.text = tempStringFahrenheit + "°"
                                                    let imgName = self.getImageName(weatherID)
                                                    self.weatherIconImg.image = UIImage(named: imgName)
                                                }
                                            }
                                            return
                                        }
                                    }
                                }
                            }
                        }
                        
                        //if enters here no weather
                        
                    }
                    
                    //       print("json dict: \(jsonDict)")
                }
                
            } catch {
                print("call weather request unsuccessful")
            }
            }.resume()
    }
    
    func isNight(hour: Int) -> Bool{
        if hour < 6 || hour > 19{
            return true
        } else{
            return false
        }
    }
    
    func kelvinToCelcius(kelvin: Double) -> String{
        return String(Int(round(kelvin * 9/5 - 459.67)))
    }
    
    func getImageName(id: Int) -> String{
        
        let interval = NSTimeInterval(self.event.timeStampOfEvent!)
        let eventDate1 = NSDate(timeIntervalSince1970: interval)
        var hour = eventDate1.hourOfDay()
        
        switch id {
        case 200..<300:
            return "weatherThunder"
        case 500..<600:
            return "weatherRain"
        case 600..<700:
            return "snow"
        case 800:
            if isNight(hour){
                return "weatherNightClear"
            } else{
                return "weatherSun"
            }
        case 801...804:
            return "weatherCloud"
        default:
            return "weatherCloud"
        }
    }
    
    
}











