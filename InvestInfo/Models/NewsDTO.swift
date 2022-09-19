//
//  NewsDTO.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import Foundation

struct NewsDTO: Codable {
    let title: String
    let body: String
    let date: Int
    
    let imageURL: String?
}
