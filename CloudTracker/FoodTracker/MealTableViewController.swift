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
        
        // fetches and loads the pictures identified
        let meal = listOfMeals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.descriptionLabel.text = meal.mealDescription
        cell.caloriesLabel.text = "\(meal.calories)"
        
        
        //if no pictures for the indexPath this is activated
        if meal.photo == nil {
            if let url = meal.photoURL {
                //load image from the meal.photoURL property.. the indexpath is responsible for organizing how the objects are broken down like assigning the image,title to each etc. and will keep getting run to load images over and over again when user scrolls.
                DataManager.loadImage(imageURL: url) { (image) in
                    //assign the loaded photo to a property so it doesnt have to load everytime.
                    meal.photo = image
                    OperationQueue.main.addOperation {
                        if cell.nameLabel.text == meal.name {
                            cell.photoImageView.image = meal.photo
                            cell.descriptionLabel.text = meal.mealDescription
                            cell.caloriesLabel.text = "\(meal.calories)"
                        }
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
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = listOfMeals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
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

