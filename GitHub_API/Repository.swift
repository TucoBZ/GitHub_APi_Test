//
//  Repository.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import Foundation
import SwiftyJSON

class Repository{
    var id: String?
    var name: String?
    var description: String?
    var ownerLogin: String?
    var url: String?
    
    required init(json: JSON) {
        self.description = json["description"].string
        self.id = json["id"].string
        self.name = json["name"].string
        self.ownerLogin = json["owner"]["login"].string
        self.url = json["url"].string
    }
}
