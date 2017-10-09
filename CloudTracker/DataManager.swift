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
            
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    
    
    
    
    
    
    
    
    //   +(void)queryProductComplete:(void (^)(NSArray<Product*> *))complete{
    //
    //    NSURL *queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://lcboapi.com/products?where=has_value_added_promotion&order=price_in_cents"]];
    //
    //    //this is when you have a header
    //    NSMutableURLRequest *reqWithHeader = [NSMutableURLRequest requestWithURL:queryURL];
    //    [reqWithHeader addValue:[NSString stringWithFormat:@"Token token=%@",LCBO_KEY] forHTTPHeaderField:@"Authorization"];
    //
    //    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:reqWithHeader completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
    //    //happening inside this block of code.
    //    // this is where we get the results
    //    if (error != nil) {
    //    NSLog(@"error in url session: %@", error.localizedDescription);
    //    abort(); // TODO: display an alert or something
    //    }
    //    // TODO: check the response code we got; if it's >= 300 something is wrong
    //    // remember to check status code, we need to cast response to a NSHTTPURLResponse
    //    if (((NSHTTPURLResponse*)response).statusCode >= 300) {
    //    NSLog(@"Unexpected http response: %@", response);
    //    abort(); // TODO: display an alert or something
    //    }
    //
    //    NSError *err = nil;
    //    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    //    if (err != nil) {
    //    NSLog(@"Something went wrong parsing JSON: %@", err.localizedDescription);
    //    abort();
    //    }
    //    //short way of doing [[NSMutableArray alloc]init];
    //    NSMutableArray<Product*> *promotionalAlcohol = [@[] mutableCopy];
    //
    //    //creates an empty array where i am accessing the dictionary-array and then saving its array to my mutable array.
    //    for (NSDictionary *LCBOInfo in result[@"result"]) {
    //
    //    //make a method here to say if json data is nil do not include in array
    //    [promotionalAlcohol addObject:[[Product alloc]initWithInfo:LCBOInfo]];
    //
    //    }
    //    //save the mutable array catphotos to the block.
    //    complete(promotionalAlcohol);
    //    
    //    }];
    //    //always set after block to make sure the program continues to run while block is retriving data.
    //    [task resume];
    //    
    //    }
    
    
    
    
    
    
    
}
