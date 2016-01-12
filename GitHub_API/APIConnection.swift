//
//  APIConnection.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD
import SwiftyJSON

protocol ConnectionDelegate {
    /**Gives a Array with new users, response from getUsers(int: Int)*/
    func updatedUsers(users: Array<User>)
    
     /**Gives a Array with searched users, response from searchForUser(name: String)*/
    func updatedSearchUsers(users: Array<User>)
    
    /**Gives a Array with new repositories, response from getRepositories(int: Int)*/
    func updatedRepositories(repositories: Array<Repository>)
    
    /**Gives a Array with searched repositories, response from searchForRepositories(name: String)*/
    func updatedSearchRepositories(repositories: Array<Repository>)
}


class APIConnection{

    var view : UIView?
    var users : Array<User>?
    var repositories : Array<Repository>?
    var delegate: ConnectionDelegate? = nil
    let manager = Alamofire.Manager.sharedInstance
    
    /**API Link with Parameters*/
    private func updateByKey(key: String, param:Dictionary<String,AnyObject>){
        showLoadingHUD()
        manager.request(.GET, "https://api.github.com/\(key)", parameters: param).responseJSON { response in
                if let value = response.result.value {
                    self.parseJSON(key, value:value)
                }
                self.hideLoadingHUD()
        }
    }
    
    /**Parse the Result value from the JSON, and call the respective Delegate*/
    private func parseJSON(key: String, value: AnyObject){
        switch key {
        case "users":
            for obj in value as! Array<AnyObject>{
                let json = JSON(obj)
                let user = User(json: json)
                self.users?.append(user)
            }
            if self.delegate != nil {
                self.delegate?.updatedUsers(self.users!)
            }
            break
            
        case "repositories":
            for obj in value as! Array<AnyObject>{
                let json = JSON(obj)
                let repo = Repository(json: json)
                self.repositories?.append(repo)
            }
            if self.delegate != nil {
                self.delegate?.updatedRepositories(self.repositories!)
            }
            break
            
        case "search/users":
            print(value)
            let items = (value as! Dictionary<String,AnyObject>)["items"]
            for obj in items as! Array<AnyObject>{
                let json = JSON(obj)
                let user = User(json: json)
                self.users?.append(user)
            }
            //Sort Array by login
            self.users? = (self.users?.sort({ $0.login < $1.login}))!
            if self.delegate != nil {
                self.delegate?.updatedSearchUsers(self.users!)
            }
            break
            
        case "search/repositories":
            print(value)
            let items = (value as! Dictionary<String,AnyObject>)["items"]
            for obj in items as! Array<AnyObject>{
                let json = JSON(obj)
                let repo = Repository(json: json)
                self.repositories?.append(repo)
            }
            //Sort Array by name
            self.repositories? = (self.repositories?.sort({ $0.name < $1.name}))!
            if self.delegate != nil {
                self.delegate?.updatedSearchRepositories(self.repositories!)
            }
            break
            
        default:
            print(value)
            break
        }
    }
    
    /**Get Users by ID*/
    func getUsers(int: Int){
        users = []
        self.updateByKey("users",param:["since" : int])
    }
    
    /**Get Repositories by ID*/
    func getRepositories(int: Int){
        repositories = []
        self.updateByKey("repositories",param:["since" : int])
    }
    
    /**Search for a user by name*/
    func searchForUser(name: String){
        users = []
        self.updateByKey("search/users",param:["q":name])
    }
    
    /**Search for a repository by name*/
    func searchForRepositories(name: String){
        users = []
        self.updateByKey("search/repositories",param:["q":name])
    }
    
    /**Get the Rate Limit to use*/
    func getRateLimit(){
        self.updateByKey("rate_limit",param:["":""])
    }
  
    /**Show the Loading HUD*/
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
    }
    
    /**Hide the Loading HUD*/
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
}
