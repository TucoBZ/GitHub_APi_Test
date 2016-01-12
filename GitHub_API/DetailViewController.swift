//
//  DetailViewController.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 12/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    // MARK: - Variables
    var repo : Array<Repository>?
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = repo?.first?.ownerLogin
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {}
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repo?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let reuseblecell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell {
            //Repository Name and Description
            if let description = repo?[indexPath.row].description{
                reuseblecell.detailTextLabel?.text = description
            }
            if let name = repo?[indexPath.row].name,let id = repo?[indexPath.row].id{
                reuseblecell.textLabel?.text = "\(name) - ID: \(id)"
            }
            //Image
            reuseblecell.imageView?.image =  UIImage(named: "githubPlaceHolder")
            cell = reuseblecell
        }
        return cell
    }
}
