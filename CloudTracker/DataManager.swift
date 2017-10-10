//
//  DataManager.swift
//  FoodTracker
//
//  Created by Paul on 2017-10-09.
//  Copyright © 2017 Jaison Bhatti. All rights reserved.
//

import UIKit

//Login request this should contain a token.
class DataManager: NSObject {
    

    func sendRequestForAllMeals() {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        guard let components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals") else { return }
        
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = "GET"
        request.addValue("M43tSTLQjmNrUjXdC3Ro4vW8", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //the data is store in here.
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // error testing
            if let error = error {
                print(#line, error.localizedDescription)
                return
            }
            
            // TODO: check the response code we got; if it's >= 300 something is wrong
            // remember to check status code, we need to cast response to a NSHTTPURLResponse
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                return
            }
            //assign the array of data equal to data
            guard let data = data else {
                return
            }
            
            //create an empty array called arrayOfFood
            var arrayOfFood = [Meal]()
            
            
            //if the jsonserialization works put it in the empty array
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? Array<Dictionary<String,Any>>  {
                    
                    for item in json {
                        arrayOfFood.append(Meal (info: item))
                        
                    }
                }
            }
                //if it doesnt work print out error
            catch {
                print(#line, error.localizedDescription)
            }
            
            print(#line, arrayOfFood)
            // completion(arrayOfMeals)
            
            
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    

    
    
//post photo to imgur
    func postPhotoToImgur() {
        let sessionConfig = URLSessionConfiguration.default
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig)
        
        /* Create the Request:
         Post image to Imgur (POST https://api.imgur.com/3/image)
         */
        
        let image = UIImage(named: "animal03")
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        
        guard let URL = URL(string: "https://api.imgur.com/3/image") else {return}
        var request = URLRequest(url: URL)
        
        
        request.httpMethod = "POST"
        // Headers
//        request.addValue("IMGURSESSION=65562fa6c2283ab470b6c7bdbf5ba115; _nc=1", forHTTPHeaderField: "Cookie")
        request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization")
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        /* Start a new Task */
        let task = session.uploadTask(with: request, from: imageData!) { (data: Data?, response: URLResponse?, error: Error?) in
            
            
            if let error = error {
                print(#line, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print(#line, "no data")
                return
            }
            
            guard let dict = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any> else {
                return
            }
            
                if let url = dict["data"] as? String {
                    print(#line, url)

            
            }
            
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    

    //post photo to imgur
//    func postPhotoToImgur() {
//        let sessionConfig = URLSessionConfiguration.default
//        /* Create session, and optionally set a URLSessionDelegate. */
//        let session = URLSession(configuration: sessionConfig)
//        
//        
//        let image = UIImage(named: "animal03")
//        let imageData = UIImageJPEGRepresentation(image!, 1.0)
//        
//        guard let URL = URL(string: "https://api.imgur.com/3/image") else {return}
//        var request = URLRequest(url: URL)
//        
//        request.httpMethod = "POST"
//        
//        // Headers
//        request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization")
//        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
//        
//        /* Start a new Task */
//        let task = session.uploadTask(with: request, from: imageData!) { (data: Data?, response: URLResponse?, error: Error?) in
//            
//            
//            if let error = error {
//                print(#line, error.localizedDescription)
//                return
//            }
//            
//            guard let data = data else {
//                print(#line, "no data")
//                return
//            }
//            
//            guard let dict = try! JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any> else {
//                return
//            }
//            
//            print(#line, dict)
//        }
//        
//        task.resume()
//        session.finishTasksAndInvalidate()
//    }
//    
    
    
    
    
    
    
    
    
    
    
    
}
