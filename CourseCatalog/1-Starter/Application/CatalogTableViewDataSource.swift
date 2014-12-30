//
//  TableViewCatalogDataSource.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/23/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import UIKit

@objc class CatalogTableViewDataSource : NSObject, CatalogDataSourceDelegate, UITableViewDataSource
{
    @IBOutlet var catalogDataSource : CatalogDataSource!
    @IBOutlet var tableView : UITableView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let courses = catalogDataSource.courses
        return courses.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let object = catalogDataSource.objectAtIndexPath(indexPath) as TableViewCellDisplayable
        cell.textLabel!.text = object.displayDescription
        return cell
    }

    func dataSourceDidAddNewObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    {
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func dataSourceDidRemoveObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
}

