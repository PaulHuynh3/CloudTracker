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
        
//        DataManager.sendGetRequestForAllMeals {(meals:[Meal]) in
//        //all the ui information goes inside the main queue.
//            OperationQueue.main.addOperation({
//                self.listOfMeals = meals
//                self.tableView.reloadData()
//                
//            })
//        }
        
 
        //network request to create meals
        DataManager.createMeal(title:"Pizza", description:"Sweet but addictive!!!!", calories:500) { (meal:Meal) in
            
            DataManager.postPhotoToImgur(image: #imageLiteral(resourceName: "pineapple"), completionHandler: { (url:URL) in
                
                DataManager.updateMealWithPhoto(meal: meal, photoURL: url, completionHandler: {
                    
                    DataManager.sendGetRequestForAllMeals(completionHandler: { (mealArray:[Meal]) in
                        
                            OperationQueue.main.addOperation {
                                self.listOfMeals = mealArray
                                self.tableView.reloadData()
                            }
                            
                            
                        
                    })
                    
                })
                
            })
            
        }
        
        
        
        
        
        
        
        
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
        
        // Fetches the appropriate meal for the data source layout.
        let meal = listOfMeals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo

//        cell.ratingControl.rating = (meal.rating?)!
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
  
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
 
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
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
    
    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                listOfMeals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                
                // Add a new meal.
                let newIndexPath = IndexPath(row: listOfMeals.count, section: 0)
                
                listOfMeals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
        }
    }
    
    
    //MARK: Private Methods
    
//    private func loadSampleMeals()
//    {
//        let photo1 = UIImage(named: "meal1")
//        let photo2 = UIImage(named: "meal2")
//        let photo3 = UIImage(named: "meal3")
//        
//        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4)
//            else
//        {
//            fatalError("Unable to instantiate meal1")
//        }
//        
//        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5)
//            else
//        {
//            fatalError("Unable to instantiate meal2")
//        }
//        
//        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3)
//            else
//        {
//            fatalError("Unable to instantiate meal2")
//        }
//        
//        //add the objects to the array of meals
//        meals += [meal1, meal2, meal3]
//    }
//    
//    
//    //DATA persist function
//    private func saveMeals () {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
//        if isSuccessfulSave {
//            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//            os_log("Failed to save meals...", log: OSLog.default, type: .error)
//        }
//    
//    }
//    
//    //Load the meal list
//    
//    private func loadMeals() -> [Meal]?  {
//        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
//    }
//    
}
