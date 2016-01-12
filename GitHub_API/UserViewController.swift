//
//  UserViewController.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import UIKit
import PINRemoteImage

final class UserViewController: UIViewController{
    
    // MARK: - Variables
    var users : Array<User>?
    var filteredArray : Array<User>?
    var connection : APIConnection?
    var searchController : UISearchController!
    var shouldShowSearchResults = false
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        users = []
        filteredArray = []
        configureSearchController()
        configureConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func configureConnection(){
        connection = APIConnection.init(connectionDelegate: self, currentView: self.view)
        connection?.getUsers(0)
    }
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {}
}

// MARK: - UITableViewDataSource
extension UserViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray?.count ?? 0
        }
        return users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let reuseblecell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell {
            if shouldShowSearchResults {
                //User Name
                if let name = filteredArray?[indexPath.row].login{
                    reuseblecell.textLabel?.text = name
                }
                //Image
                if let imageURL = filteredArray?[indexPath.row].avatar_url{
                    reuseblecell.imageView?.pin_setImageFromURL(NSURL(string:imageURL), placeholderImage: UIImage(named: "githubPlaceHolder"))
                }
            } else {
                //User Name
                if let name = users?[indexPath.row].login, let id = users?[indexPath.row].id{
                    reuseblecell.textLabel?.text = "\(name) - ID: \(id)"
                    if users!.count-1 == indexPath.row{
                        connection?.getUsers(id)
                    }
                }
                //Image
                if let imageURL = users?[indexPath.row].avatar_url{
                    reuseblecell.imageView?.pin_setImageFromURL(NSURL(string:imageURL), placeholderImage: UIImage(named: "githubPlaceHolder"))
                }
            }
            cell = reuseblecell
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension UserViewController: UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {}
    
}

// MARK: - UISearchResultsUpdating
extension UserViewController: UISearchResultsUpdating {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        filteredArray = []
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        filteredArray = []
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            connection?.searchForUser(searchBar.text!)
        }
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - ConnectionDelegate
extension UserViewController: ConnectionDelegate {
    
    func updatedUsers(users: Array<User>) {
        self.users?.appendAll(users)
        tableView?.reloadData()
    }
    
    func updatedSearchUsers(users: Array<User>) {
        filteredArray = users
        tableView?.reloadData()
    }
    
    func updatedRepositories(repositories: Array<Repository>) {}
    func updatedSearchRepositories(repositories: Array<Repository>){}
}
