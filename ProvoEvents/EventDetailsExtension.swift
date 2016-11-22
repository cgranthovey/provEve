//
//  AddEventExtenstion.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 10/21/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import Foundation


extension EventDetailsVC{
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //get weather info
    
    func callWeather(_ eventTime: Int){
        
        var eventWeatherDict: Dictionary<String, AnyObject>!
        let longitudeRounded =  Double(round(1000 * event.pinInfoLongitude!) / 1000)
        let longitudeString = String(longitudeRounded)
        let latitudeRounded = Double(round(1000 * event.pinInfoLatitude!) / 1000)
        let latidudeString = String(latitudeRounded)
        let endPoint: String = "http://api.openweathermap.org/data/2.5/forecast?APPID=e8535c81703fe79f0f17726667bc0c27&lat=\(latidudeString)&lon=\(longitudeString)"
        let url = URL(string: endPoint)!
        let session = URLSession.shared

        session.dataTask(with: url) { (data, response, error) in
            do {
                guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else{
                    print("not a 200 response")
                    return
                }
                if NSString(data: data!, encoding: String.Encoding.utf8.rawValue) != nil{
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if let threeHourArray = jsonDict["list"] as? [Dictionary<String, AnyObject>]{
                        for three in threeHourArray{
                            if let threeTime = three["dt"] as? Int{
                                if eventTime <= threeTime{
                                    eventWeatherDict = three
                                    if let main = eventWeatherDict["main"] as? Dictionary<String, AnyObject>, let weatherArray = eventWeatherDict["weather"] as? [Dictionary<String, AnyObject>]{
                                        let weatherDesc = weatherArray[0] as Dictionary<String, AnyObject>
                                            if let eventTemp = main["temp"] as? Double, let eventWeatherDesc = weatherDesc["description"] as? String, let weatherID = weatherDesc["id"] as? Int{
                                                let tempStringFahrenheit = self.kelvinToCelcius(eventTemp)
                                                DispatchQueue.main.async{
                                                    self.weatherTemp.text = tempStringFahrenheit + "°"
                                                    let imgName = self.getImageName(weatherID)
                                                    self.weatherIconImg.image = UIImage(named: imgName)
                                                    self.weatherDescLbl.text = eventWeatherDesc
                                                }
                                            }
                                            return
                                    }
                                }
                            }
                        }
                        //no weather
                    }
                }
            } catch {
                print("call weather request unsuccessful")
            }
            }.resume()
    }
    
    func isNight(_ hour: Int) -> Bool{
        if hour < 6 || hour > 19{
            return true
        } else{
            return false
        }
    }
    
    func kelvinToCelcius(_ kelvin: Double) -> String{
        return String(Int(round(kelvin * 9/5 - 459.67)))
    }
    
    func getImageName(_ id: Int) -> String{
        let interval = TimeInterval(self.event.timeStampOfEvent!)
        let eventDate1 = Date(timeIntervalSince1970: interval)
        let hour = eventDate1.hourOfDay()
        switch id {
        case 200..<300:
            return "thunder"
        case 500..<600:
            return "rain"
        case 600..<700:
            return "snow"
        case 800:
            if isNight(hour){
                return "moon"
            } else{
                return "sun"
            }
        case 801...804:
            return "cloud"
        default:
            return "cloud"
        }
    }
}
