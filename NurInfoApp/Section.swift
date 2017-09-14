//
//  Section.swift
//  NurInfoApp
//
//  Created by Mohamed Elmoghazi on 8/23/17.
//  Copyright © 2017 Nursing Informatics Department. All rights reserved.
//

import Foundation

struct Section {
    var title: String!
    var documents: [String]!
    var expanded: Bool!
    
    init(title: String, documents: [String], expanded: Bool) {
        self.title = title
        self.documents = documents
        self.expanded = expanded
    }
}
