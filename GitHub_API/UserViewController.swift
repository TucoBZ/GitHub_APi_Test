//
//  UserViewController.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import UIKit
import PINRemoteImage

class UserViewController: UIViewController, ConnectionDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    
    // MARK: - Variables
    
    var users : Array<User>?
    var filteredArray : Array<User>?
    
    var connection = APIConnection.init()
    var searchController : UISearchController!
    var shouldShowSearchResults = false
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - TableViewDelegate and DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray!.count
        }
        return users!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        if shouldShowSearchResults {
            
            //User Name
            cell.textLabel?.text = "\(self.filteredArray![indexPath.row].login!)"
            
            //Image Pin
            let imageURL = NSURL(string: self.filteredArray![indexPath.row].avatar_url!)
            cell.imageView?.pin_setImageFromURL(imageURL, placeholderImage: UIImage(named: "githubPlaceHolder"))
            
            return cell

        }
        //User Name
        cell.textLabel?.text = "\(self.users![indexPath.row].login!) - ID: \(self.users![indexPath.row].id!)"
        
        //Image Pin
        let imageURL = NSURL(string: self.users![indexPath.row].avatar_url!)
        cell.imageView?.pin_setImageFromURL(imageURL, placeholderImage: UIImage(named: "githubPlaceHolder"))
        
        if self.users!.count-1 == indexPath.row{
            self.connection.getUsers(self.users![indexPath.row].id!)
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    // MARK: - UISearchResultsUpdating, Delegate and Congiguration
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        // Place the search bar view to the tableview headerview.
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.filteredArray = []
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.filteredArray = []
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            //tableView.reloadData()
            self.connection.searchForUser(searchBar.text!)
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       
        
    }
    
    // MARK: - ConnectionDelegate
    
    func updatedUsers(users: Array<User>) {
        self.users?.appendAll(users)
        self.tableView?.reloadData()
    }
    
    func updatedRepositories(repositories: Array<Repository>) {}

    func updatedSearchUsers(users: Array<User>) {
        self.filteredArray = users
        self.tableView?.reloadData()
    }
    
    func updatedSearchRepositories(repositories: Array<Repository>){}
    
    // MARK: - ConnectionDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = []
        filteredArray = []
        configureSearchController()
        
        self.connection.view = self.view
        self.connection.delegate = self

        //self.connection.logintest("login", pass: "password")
        self.connection.getUsers(0)
        self.connection.getRateLimit()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
}

