//
//  RepositoryViewController.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import UIKit
import PINRemoteImage

final class RepositoryViewController: UIViewController {
    
    // MARK: - Variables
    var repo : Array<Repository>?
    var filteredArray : Array<Repository>?
    var connection = APIConnection.init()
    var searchController : UISearchController!
    var shouldShowSearchResults = false
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        repo = []
        filteredArray = []
        configureSearchController()
        configureConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureConnection(){
        self.connection.view = self.view
        self.connection.delegate = self
        self.connection.getRepositories(0)
        self.connection.getRateLimit()
    }
    
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
    
}

// MARK: - UITableViewDelegate
extension RepositoryViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {}
}

// MARK: - UITableViewDataSource
extension RepositoryViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray!.count
        }
        return repo!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let reuseblecell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell {
            if shouldShowSearchResults {
                //Repository Name and Description
                if let name = filteredArray?[indexPath.row].name{
                    reuseblecell.textLabel?.text = name
                }
                if let description = filteredArray?[indexPath.row].description {
                    reuseblecell.detailTextLabel?.text = description
                }
            } else {
                //Repository Name and Description
                if let description = repo?[indexPath.row].description{
                    reuseblecell.detailTextLabel?.text = description
                }
                if let name = repo?[indexPath.row].name,let id = repo?[indexPath.row].id{
                        reuseblecell.textLabel?.text = "\(name) - ID: \(id)"
                        if self.repo!.count-1 == indexPath.row{
                            self.connection.getRepositories(id)
                        }
                }
            }
            //Image
            reuseblecell.imageView?.image =  UIImage(named: "githubPlaceHolder")
            cell = reuseblecell
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension RepositoryViewController: UISearchBarDelegate {

    func updateSearchResultsForSearchController(searchController: UISearchController) {}

}

// MARK: - UISearchResultsUpdating
extension RepositoryViewController: UISearchResultsUpdating {
    
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
            self.connection.searchForRepositories(searchBar.text!)
        }
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - ConnectionDelegate
extension RepositoryViewController: ConnectionDelegate {
    
    func updatedUsers(users: Array<User>) {}
    func updatedSearchUsers(users: Array<User>) {}
    
    func updatedRepositories(repositories: Array<Repository>) {
        self.repo?.appendAll(repositories)
        self.tableView?.reloadData()
    }
    
    func updatedSearchRepositories(repositories: Array<Repository>){
        self.filteredArray = repositories
        self.tableView?.reloadData()
    }
}
