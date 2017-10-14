//
//  Meal.swift
//  FoodTracker
//
//  Created by Paul on 2017-10-08.
//  Copyright © 2017 Paul. All rights reserved.
//

import UIKit
import os.log

class Meal: CustomStringConvertible {
    
    //MARK: Properties
    var name: String
    var photo: UIImage? = nil
    var photoURL: URL?
    var rating: Int?
    var mealDescription: String
    var calories: Int
    var mealID: Int
    
    
    //MARK: Initialization
    //init will fail if there is no name or if the rating is negative
//    init?(name: String, photo: UIImage?, rating: Int)
//    {
//        
//        
//        // The name must not be empty
//        guard !name.isEmpty else {
//            return nil
//        }
//        
//        // The rating must be between 0 and 5 inclusively
//        guard (rating >= 0) && (rating <= 5) else {
//            return nil
//        }
//    
//        // Initialize stored properties.
//        self.name = name
//        self.photo = photo
//        self.rating = rating
//        
//    }
    
    
    //MARK: iniatilize with json data.
    init(info: Dictionary<String, Any>){
        self.name = info["title"] as! String
        if let imagePath = info["imagePath"] as? String {
        self.photoURL = URL(string: imagePath)
        }
        self.mealDescription = info["description"] as! String
        self.calories = info["calories"] as! Int
        self.rating = info["rating"] as? Int
        self.mealID = info["id"] as! Int
    }
    

    
    
    
    var description: String {
        return "some description"
    }
    
    func loadImage(done: @escaping () -> Void) {
        if (photo != nil) {
            done()
            return
        }
        guard let photoURL =  photoURL else {
            return
        }
        DataManager.loadImage(imageURL: photoURL) { (photoImage) in
            self.photo = photoImage
            done()
        }
    }
}
