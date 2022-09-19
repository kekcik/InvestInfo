//
//  RatesInfoDTO.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import Foundation

class RatesInfoDTO: Codable {
    let ValCursDate: Int
    let ValCurs: [RateDTO]
}
