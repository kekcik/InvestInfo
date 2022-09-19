//
//  RateDTO.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import Foundation

class RateDTO: Codable {
    let NumCode: Int
    let CharCode: String
    let Nominal: Int
    let Name: String
    let Value: String
}
