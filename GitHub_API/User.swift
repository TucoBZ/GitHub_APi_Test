//
//  User.swift
//  GitHub_API
//
//  Created by Túlio Bazan da Silva on 11/01/16.
//  Copyright © 2016 TulioBZ. All rights reserved.
//

import Foundation
import SwiftyJSON

class User{
    var id: Int?
    var login: String?
    var repos_url: String?
    var avatar_url: String?
    var url: String?
    
    required init(json: JSON) {
        self.repos_url = json["repos_url"].string
        self.id = json["id"].int
        self.login = json["login"].string
        self.avatar_url = json["avatar_url"].string
        self.url = json["url"].string
    }

}
