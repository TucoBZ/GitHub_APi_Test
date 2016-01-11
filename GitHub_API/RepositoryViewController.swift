//
//  RepositoryViewController.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import UIKit
import PINRemoteImage

class RepositoryViewController: UIViewController, ConnectionDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    
    // MARK: - Variables
    
    var repo : Array<Repository>?
    var filteredArray : Array<Repository>?
    
    var connection = APIConnection.init()
    var searchController : UISearchController!
    var shouldShowSearchResults = false
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - TableViewDelegate and DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray!.count
        }
        return repo!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        if shouldShowSearchResults {
            
            //User Name
            cell.textLabel?.text = "\(self.filteredArray![indexPath.row].name!)"
            cell.detailTextLabel?.text = self.filteredArray![indexPath.row].description!
            
            //Image
            cell.imageView?.image =  UIImage(named: "githubPlaceHolder")
            
            return cell
            
        }
        
        //User Name
        cell.textLabel?.text = "\(self.repo![indexPath.row].name!) - ID: \(self.repo![indexPath.row].id!)"
        cell.detailTextLabel?.text = self.repo![indexPath.row].description!
        
        //Image
        cell.imageView?.image =  UIImage(named: "githubPlaceHolder")
        
        if self.repo!.count-1 == indexPath.row{
            self.connection.getRepositories(self.repo![indexPath.row].id!)
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
            self.connection.searchForRepositories(searchBar.text!)
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
    }
    
    // MARK: - ConnectionDelegate
    
    func updatedUsers(users: Array<User>) {}
    
    func updatedRepositories(repositories: Array<Repository>) {
        self.repo?.appendAll(repositories)
        self.tableView?.reloadData()
    }
    
    func updatedSearchUsers(users: Array<User>) {}
    
    func updatedSearchRepositories(repositories: Array<Repository>){
            self.filteredArray = repositories
            self.tableView?.reloadData()
    }
    
    // MARK: - ConnectionDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repo = []
        filteredArray = []
        configureSearchController()
        
        self.connection.view = self.view
        self.connection.delegate = self
        
        //self.connection.logintest("login", pass: "password")
        self.connection.getRepositories(0)
        self.connection.getRateLimit()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
