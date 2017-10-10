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
    

    class func sendGetRequestForAllMeals(completionHandler: @escaping ([Meal]) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        guard let components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals") else { return }
        
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = "GET"
        request.addValue("M43tSTLQjmNrUjXdC3Ro4vW8", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //the data is store in "data"
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
                    
                    //save the meal's iniatlizer class as the item.
                    for item in json {
                        arrayOfFood.append(Meal (info: item))
                        
                    }
                }
            }
                //if it doesnt work print out error
            catch {
                print(#line, error.localizedDescription)
            }
            
            
            //save the array to completion handler
            completionHandler(arrayOfFood)
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    


    

    //post photo to imgur
    class func postPhotoToImgur(image: UIImage, completionHandler: @escaping (URL) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig)
        
        
//        let image = UIImage(named: "animal03") // later, this will be an a
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        guard let url = URL(string: "https://api.imgur.com/3/image") else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization") // maybe later, make the credentials dynamic, so it isn't in the code base
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
            
            print(#line, dict)
            
            guard
                let dataDict = dict["data"] as? Dictionary<String,Any>,
                let linkStr = dataDict["link"] as? String,
                let link = URL(string: linkStr)
                else { print(#line, "Couldn't get link from response"); return }
            
            completionHandler(link)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
 
    class func createMeal(mealInfo: Dictionary<String,Any>, completionHandler: @escaping (Meal) -> Void) {
        // send a post request to the appropriate cloud tracker API
        let url = URL(string: "")!
        let data = try! JSONSerialization.data(withJSONObject: mealInfo, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        // set headers as needed
        // have token loaded from Secrets file or something
        request.addValue("M43tSTLQjmNrUjXdC3Ro4vW8", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send the request
        // get Meal object from response
        // completionHandler(mealFromResponse)
        
    }
    
    class func updateMealPhoto(meal: Meal, photoURL: URL, completionHandler: @escaping () -> Void) {
        //build URL to cloudtracker api endpoint for this meal object
        //  "https://cloud-tracker.herokuapp.com/users/me/meals/ meal.id /photo
        //     urlcomponents query: photo= photoURL
        // send request, call completionHandler on done
    }
    
    
    class func loadImage(imageURL: URL, completionHandler: @escaping (UIImage) -> Void) {
        // same way of loading images from URL you've done before
    }
}

// in some other class, whereever you're getting the info to create objects:
func doIt(info: Dictionary<String,Any>, photo: UIImage) {
    DataManager.createMeal(mealInfo: info) { (newMeal) in
        // save newMeal somewhere (put it in array?)
        newMeal.photo = photo
        DataManager.postPhotoToImgur(image: photo, completionHandler: { (photoURL) in
                DataManager.updateMealPhoto(meal: newMeal, photoURL: photoURL, completionHandler: { 
                    print("updated meal photo")
                })
        })
    }
}
