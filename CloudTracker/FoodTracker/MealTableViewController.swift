//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Paul on 2017-10-08.
//  Copyright © 2017 Paul. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController
{
    
    //MARK: Properties
    
    var listOfMeals = [Meal]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        DataManager.sendGetRequestForAllMeals(completionHandler: { (mealArray:[Meal]) in
            
            OperationQueue.main.addOperation {
                self.listOfMeals = mealArray
                self.tableView.reloadData()
            }
        })
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listOfMeals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        //guard let safely unwraps the optional
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell
            else
        {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // fetches and loads all the text.. except the image! The mealsArray contains 8 elements this will be loaded one at a time and start again until all 8 elements are loaded.
        let meal = listOfMeals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.descriptionLabel.text = meal.mealDescription
        cell.caloriesLabel.text = "\(meal.calories)"
        
        
        //it runs through the above code once and the image wasn't loaded this will hit. it will keep doing this until all images are loaded.
        //This should happen when simulator is click play initially because photos havent been loaded.
        if meal.photo == nil {
     
                //load image from the meal.photoURL property.. the indexpath is responsible for organizing how the objects are broken down like assigning the image,title to each etc. and will keep getting run to load images over and over again when user scrolls.
                DataManager.loadImage(imageURL: meal.photoURL!) { (image) in
                    
                    //assign the loaded photo to a property so it doesnt have to load everytime. This is very important!
                    meal.photo = image
                    
                   
                    OperationQueue.main.addOperation {
                //after all the pictures have been loaded it goes into here. pictures have to be loaded but words and texts do not.. so it waits for all the images to load before it populates.
                        if cell.nameLabel.text == meal.name {
                            cell.photoImageView.image = meal.photo
                            cell.descriptionLabel.text = meal.mealDescription
                            cell.caloriesLabel.text = "\(meal.calories)"
                        }
                    }
                }
            
        }
        
        return cell
    }
    
    
    
    // Allows delete functionality in main view!
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            listOfMeals.remove(at: indexPath.row)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        //different case for different scenarios
        case "AddItem": //segue has to go through the navigationcontroller of the mealTableViewController so it can see a blank table. instead of directly to the mealTableViewController!!!!!
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = listOfMeals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: UNWIND segue.
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        //setting the sender source as mealviewcontroller (where the data is coming from)
        if let sourceViewController = sender.source as? MealViewController {
            
            //update meal if user changes the already made meal
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                listOfMeals[selectedIndexPath.row] = sourceViewController.meal!
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                
                // Add a new meal.
                let newIndexPath = IndexPath(row: listOfMeals.count, section: 0)
                
                
                //network request to create meals (when user hits the save button from MealViewController...
                DataManager.createMeal(title:sourceViewController.nameTextField.text!, description:sourceViewController.descriptionTextField.text!, calories:Int(sourceViewController.caloriesTextField.text!)!) { (meal:Meal) in
                    
                    DataManager.postPhotoToImgur(image:sourceViewController.photoImageView.image!, completionHandler: { (url:URL) in  
                        
                        DataManager.updateMealWithPhoto(meal: meal, photoURL: url, completionHandler: {
                            
                            OperationQueue.main.addOperation {
                                
                                //You never set the meal image to the URL you receive..
                                //But other than that, everything works..
                                //Yup, uploads successfully but meal.image and meal.photoURL = nil because you never set it to the response..
                                sourceViewController.meal = meal
                                
                                self.listOfMeals.append(meal)
                                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                            }
                            
                        })
                        
                    })
                    
                }
            }
            
        }
    }
}

