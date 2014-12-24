//
//  DetailViewController.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/6/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel?

    var detailItem: AnyObject?
    {
        didSet
        {
            configureView()
        }
    }

    func configureView() {
        detailDescriptionLabel?.text = detailItem?.description
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
    }

}

