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
    
    convenience init(connectionDelegate: ConnectionDelegate, currentView: UIView){
        self.init()
        delegate = connectionDelegate
        view = currentView
    }
    
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
                users?.append(user)
            }
            if delegate != nil {
                delegate?.updatedUsers(self.users!)
            }
            break
            
        case "repositories":
            for obj in value as! Array<AnyObject>{
                let json = JSON(obj)
                let repo = Repository(json: json)
                repositories?.append(repo)
            }
            if delegate != nil {
                delegate?.updatedRepositories(repositories!)
            }
            break
            
        case "search/users":
            let items = (value as! Dictionary<String,AnyObject>)["items"]
            for obj in items as! Array<AnyObject>{
                let json = JSON(obj)
                let user = User(json: json)
                users?.append(user)
            }
            //Sort Array by login
            users? = (users?.sort({ $0.login < $1.login}))!
            if delegate != nil {
                delegate?.updatedSearchUsers(users!)
            }
            break
            
        case "search/repositories":
            let items = (value as! Dictionary<String,AnyObject>)["items"]
            for obj in items as! Array<AnyObject>{
                let json = JSON(obj)
                let repo = Repository(json: json)
                repositories?.append(repo)
            }
            //Sort Array by name
            repositories? = (repositories?.sort({ $0.name < $1.name}))!
            if delegate != nil {
                delegate?.updatedSearchRepositories(repositories!)
            }
            break
            
        case "rate_limit":
            print(value)
            break
            
        default:
            //Call Back from "users/\(name)/repos" like
            for obj in value as! Array<AnyObject>{
                let json = JSON(obj)
                let repo = Repository(json: json)
                repositories?.append(repo)
            }
            if delegate != nil {
                delegate?.updatedRepositories(repositories!)
            }

            break
        }
    }
    
    /**Get Users by ID*/
    func getUsers(int: Int){
        users = []
        updateByKey("users",param:["since" : int])
    }
    
    /**Get Repositories by ID*/
    func getRepositories(int: Int){
        repositories = []
        updateByKey("repositories",param:["since" : int])
    }
    
    /**Search for a user by name*/
    func searchForUser(name: String){
        users = []
        updateByKey("search/users",param:["q":name])
    }
    
    /**Search for a repository by name*/
    func searchForRepositories(name: String){
        users = []
        updateByKey("search/repositories",param:["q":name])
    }
    
    /**Get Repositories from a user*/
    func getRepositoriesFromUser(name: String){
        repositories = []
        updateByKey("users/\(name)/repos",param:["":""])
        
    }
    
    /**Get the Rate Limit to use*/
    func getRateLimit(){
        updateByKey("rate_limit",param:["":""])
    }
  
    /**Show the Loading HUD*/
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = "Loading..."
    }
    
    /**Hide the Loading HUD*/
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
}
