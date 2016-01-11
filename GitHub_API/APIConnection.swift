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
import PINRemoteImage

protocol ConnectionDelegate {
    func updatedUsers(users: Array<User>)
    func updatedSearchUsers(users: Array<User>)
    func updatedRepositories(repositories: Array<Repository>)
}


class APIConnection{

    var view : UIView?
    var users : Array<User>?
    var repositories : Array<Repository>?
    var delegate: ConnectionDelegate? = nil
    
    static let sharedInstance = APIConnection()
    
    
    func logintest(user: String, pass: String){
        
        let credentialData = "\(user):\(pass)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        
        Alamofire.request(.GET, "https://api.github.com/user", headers: headers)
            .responseJSON { response in
                debugPrint(response)
                
                self.getRateLimit()
        }
    }
    
    func updateByKey(key: String, param:Dictionary<String,AnyObject>){
        
        showLoadingHUD()
        
        print("https://api.github.com/\(key)")
        
        Alamofire.request(.GET, "https://api.github.com/\(key)", parameters: param).responseJSON { response in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
            
           
                if let value = response.result.value {
                    
                    self.parseJSON(value, key: key)
                }
                
                self.hideLoadingHUD()

        }

    }
    
    func parseJSON(value: AnyObject, key: String){
        switch key {
            
        case "users":
            for obj in value as! Array<AnyObject>{
                let json = JSON(obj)
                //print("JSON: \(json)")
                let user = User(json: json)
                self.users?.append(user)
                print(user.id)
            }
            
//            //Sort Array by ID
//            self.users? = (self.users?.sort({ $0.id < $1.id}))!
            
            if self.delegate != nil {
                self.delegate?.updatedUsers(self.users!)
            }
            break
            
        case "repositories":
            for obj in value as! Array<AnyObject>{
                let json = JSON(obj)
                //print("JSON: \(json)")
                let repo = Repository(json: json)
                self.repositories?.append(repo)
            }
            
//            //Sort Array by ID
//            self.repositories? = (self.repositories?.sort({ $0.id < $1.id}))!
            
            if self.delegate != nil {
                self.delegate?.updatedRepositories(self.repositories!)
            }
            break
            
        case "search/users":
            print(value)
            let items = (value as! Dictionary<String,AnyObject>)["items"]
            for obj in items as! Array<AnyObject>{
                let json = JSON(obj)
                //print("JSON: \(json)")
                let user = User(json: json)
                self.users?.append(user)
                print(user.id)
            }
           
            //Sort Array by Login
            self.users? = (self.users?.sort({ $0.login < $1.login}))!
            
            if self.delegate != nil {
                self.delegate?.updatedSearchUsers(self.users!)
            }
            break
            
        
        default:
            print(value)
            break
        }
        
    }
    
    func getUsers(int: Int){
        users = []
        self.updateByKey("users",param:["since" : int])
    }
    
    func getRepositories(){
        repositories = []
        self.updateByKey("repositories",param:["":""])
    }
    
    func getRateLimit(){
      self.updateByKey("rate_limit",param:["":""])
    }
    
    func searchForUser(name: String){
        users = []
        self.updateByKey("search/users",param:["q":name])
    }
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
}
