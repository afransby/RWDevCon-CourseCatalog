//
//  CourseraCatalogCommandHandler.swift
//  CourseCatalog
//
//  Created by Saul Mora on 12/6/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//

import Foundation

protocol Command
{
    func execute()
}

struct RetrieveCourseraCatalogCommand : Command {

    func execute()
    {

    }
}

struct NetworkRequestCommandHandler
{
    var baseURL = NSURL(string: "https://api.coursera.org/api/catalog.v1/")!

    func execute(command:Command)
    {
    }
}