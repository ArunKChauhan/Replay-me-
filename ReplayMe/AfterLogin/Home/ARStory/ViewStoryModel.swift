//
//  ViewStoryModel.swift
//  Bar Nights
//
//  Created by Core Techies on 04/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import Foundation
struct UserDetails {
    var name: String = ""
    var imageUrl: String = ""
    var userId: String = ""
    
    var content: [RMContent] = []
    
    init(userDetails: [String: Any]) {
        name = userDetails["firstName"] as? String ?? ""
        imageUrl = userDetails["imageUrl"] as? String ?? ""
        userId = userDetails["_id"] as? String ?? ""
        //"https://randomuser.me/api/portraits/men/82.jpg"
        let aContent = userDetails["content"] as? [[String : Any]] ?? []
        for element in aContent {
            content += [RMContent(element: element)]
        }
    }
}

struct RMContent {
    var type: String
    var url: String
    init(element: [String: Any]) {
        type = "video"
        url = element["videoUrl"] as? String ?? ""
    }
}
