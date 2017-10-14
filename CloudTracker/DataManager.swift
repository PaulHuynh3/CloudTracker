//
//  DataManager.swift
//  FoodTracker
//
//  Created by Paul on 2017-10-09.
//  Copyright © 2017 Jaison Bhatti. All rights reserved.
//

import UIKit

//class func means i dont have to call dataManager to use these functions
class DataManager: NSObject {
    
    //MARK: Create Signin for User
    class func createSignIn(username:String, password:String, completionHandler: @escaping (String) -> Void) {
    
    //create session
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig)
        guard let url = URL(string: "https://cloud-tracker.herokuapp.com/signup?username=\(username)&password=\(password)") else {
            return
        }
    //Providing details about the request
     var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        _ = session.dataTask(with: request) { (data:Data?, urlResponse:URLResponse?, error:Error?) in
            
            if let error = error {
                print(#line, error.localizedDescription)
            }
            
            guard let data = data else{
            return
            }
            
            
            guard let json = try! JSONSerialization.jsonObject(with:data) as? Dictionary<String,Any> else{
                return
            }

            guard let dataString = json["token"] as? String else{
            return
            }
            
            completionHandler(dataString)
        }

    }
    
    
    //MARK: Get Network Request For All Meals
    
    class func sendGetRequestForAllMeals(completionHandler: @escaping ([Meal]) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        guard let components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals") else { return }
        
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = "GET"
        request.addValue("nNtGmqjVPuHQVgDF5EmKVrYX", forHTTPHeaderField: "token")
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
                        arrayOfFood.append(Meal(info: item))
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
    
    //MARK: Get Meal by ID
    
    class func getRequestMealID(mealID:Int, completionHandler: @escaping (Meal) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        guard let components = URLComponents(string:"https://cloud-tracker.herokuapp.com/users/me/meals/\(mealID)")
            else { return }
        
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = "GET"
        request.addValue("nNtGmqjVPuHQVgDF5EmKVrYX", forHTTPHeaderField: "token")
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
            
            
            
            //if the jsonserialization works assign it to the specificMeal....[String:[String:Any]] is accessing "meal" :"key":Any
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Dictionary<String, Any>>  {
                    
                    //assign the meal object to the json by using the Meal's alloc initDictionary
                    let specificMeal = Meal(info:json["meal"]!)
                    
                    
                    
                    //save the variable json to completion handler
                    completionHandler(specificMeal)
                    
                }
            }
                //if it doesnt work print out error
            catch {
                print(#line, error.localizedDescription)
            }
            
            
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    
    
    //MARK: Post photo to imgur
    //takes in a picture and completion block returns a url.
    class func postPhotoToImgur(image: UIImage, completionHandler: @escaping (URL) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig)
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        guard let url = URL(string: "https://api.imgur.com/3/image") else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization") // maybe later, make the credentials dynamic, so it isn't in the code base
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        
        //start a new task... Uploading the image to imgur... pictures uploading and downloading typically use Data
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
            
            guard
                //access the json first dictionary level
                let dataDict =  dict["data"] as? Dictionary<String, Any>,
                //access the object's string
                let linkString = dataDict["link"] as? String,
                //turning the json's string into a url
                let link = URL(string: linkString)
                else { print(#line, "Couldn't get link from response"); return }
            
            //completionHandler returns a url of the picture the useer puts in.
            completionHandler(link)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    
    //MARK: Create meal object w/o the image url
    
    class func createMeal(title:String,description:String,calories:Int, completionHandler: @escaping (Meal) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let spacelessdescription = description.replacingOccurrences(of: " ", with: "%20")
        guard let components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals?title=\(title)&description=\(spacelessdescription)&calories=\(calories)") else {
            return
        }
        
        var request = URLRequest(url: components.url!)
        
        
        request.httpMethod = "POST"
        // set headers as needed
        request.addValue("nNtGmqjVPuHQVgDF5EmKVrYX", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        //
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                return print(#line,error.localizedDescription)
            }
            
            
            guard let data = data else{
                print ("error in datahandling")
                return
            }
            
            do {
                guard let jsonMeal = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Dictionary<String,Any>> else {
                    return
                }
                
                //return the created meal into completion handler
                let createMeal = Meal(info: jsonMeal["meal"]!)
                
                //completion handler returns a meal!
                completionHandler(createMeal)
            }
            catch {
                print(#line,error.localizedDescription)
            }
            
            
        }
        task.resume()
        session.finishTasksAndInvalidate()
        
        
    }
    
    
    //MARK: Update photos with the meal and picture.
    
    class func updateMealWithPhoto(meal: Meal, photoURL: URL, completionHandler: @escaping () -> Void) {
        //since im updating photo with meal i need to receive the url link from imgur and capture it inside my property.. else it will never happen
        
        //sets the photoURL property as the receiving PhotoURL...
        meal.photoURL = photoURL;
        //sets the photoImage property equal to the contents of the url..
        meal.photo = try! UIImage(data: Data(contentsOf: photoURL))
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        guard let components = URLComponents(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(meal.mealID)/photo?photo=\(photoURL)") else {
            return
        }
        
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = "POST"
        request.addValue("nNtGmqjVPuHQVgDF5EmKVrYX", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                return print(#line,error.localizedDescription)
            }
            
            
            guard let data = data else{
                print ("error in datahandling")
                return
            }
            
            do {
                guard let jsonMeal = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Dictionary<String,Any>> else {
                    return
                }
                
                //don't need to add this to completion block as the top code already did a POST for photo with image.. just have to call the function completionHandler.
                _ = Meal(info: jsonMeal["meal"]!)
                
                //access the urlString of the json data..
                let urlStr = jsonMeal["meal"]?["imagePath"] as! String
                
                //set the urlStr as the property's url.
                meal.photoURL = URL(string: urlStr)
                
                //completion handler
                completionHandler()
                
            }
            catch {
                print(#line,error.localizedDescription)
            }

        }
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    
    //MARK: Load images.
    
    class func loadImage(imageURL: URL, completionHandler: @escaping (UIImage) -> Void) {
                
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: imageURL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else {
                return
            }
            if let image = UIImage(data: data) {
                completionHandler(image)
            }
            
        }
        task.resume()
        
    }
    
    
}







