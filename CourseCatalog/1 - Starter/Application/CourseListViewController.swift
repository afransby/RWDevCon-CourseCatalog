//
//  MasterViewController.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/6/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import UIKit
import Argo

@objc class CourseListViewController: UIViewController, UITableViewDelegate, CatalogDataSourceDelegate
{
    @IBOutlet var tableView : UITableView!
    @IBOutlet var dataSource : CatalogDataSource!
    {
        didSet {
            dataSource.delegate = self
        }
    }

    var detailViewController: CourseViewController? = nil

    override func awakeFromNib()
    {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.rightBarButtonItem = createAddButton()
        setupSplitViewController()
    }

    func setupSplitViewController()
    {
        if let splitViewController = splitViewController
        {
            let controllers = splitViewController.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? CourseViewController
        }
    }

    func createAddButton() -> UIBarButtonItem
    {
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: dataSource, action: "addNewObject")
        return addButton
    }

    func dataSourceDidAddNewObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    {
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func dataSourceDidRemoveObject(dataSource:CatalogDataSource, atIndexPath indexPath:NSIndexPath)
    {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }

    func configureCourseViewController(controller:CourseViewController, indexPath:NSIndexPath)
    {
        let object = dataSource.objectAtIndexPath(indexPath)
        controller.detailItem = object
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showCourse"
        {
            showSegue <^>
                segue <*>
                tableView.indexPathForSelectedRow()
        }
    }

    func showSegue(segue:UIStoryboardSegue)(toDetailsAtIndexPath indexPath:NSIndexPath)
    {
        let controller = (segue.destinationViewController as UINavigationController).topViewController as CourseViewController

        configureCourseViewController(controller, indexPath: indexPath)
    }

//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
//    {
//        if editingStyle == .Delete
//        {
//            dataSource.removeObjectAtIndexPath(indexPath)
//        }
//    }
}
