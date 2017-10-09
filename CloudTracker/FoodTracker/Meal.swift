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
    var photo: UIImage?
    var rating: Int?
    var mealDescription: String
    var calories: Int
    
    
    
    //MARK: iniatilize with json data.
    init(info: Dictionary<String, Any>){
      self.name = info["title"] as! String
      self.photo = info["imagePath"] as? UIImage
      self.mealDescription = info["description"] as! String
      self.calories = info["calories"] as! Int
      self.rating = info["rating"] as? Int
        
        
        
    }
    
    var description: String {
        return "some description"
    }
    
    
    
    
    
    
    
    
    
    
    
}
