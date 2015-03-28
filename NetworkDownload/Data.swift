//
//  Data.swift
//  NetworkDownload
//
//  Created by David Doan on 3/28/15.
//  Copyright (c) 2015 David Doan. All rights reserved.
//

import Foundation

struct SessionProperties {
    static let identifier : String! = "url_session_background_download"
}

func getData() -> Array<String> {
    var data : [String] = [
        "http://web.mit.edu/21w.789/www/papers/griswold2004.pdf"
    ]
    
    return data
}