//
//  RateCell.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

struct RateCellVM: CommonCellVM {
    let classId = "RateCell"

    let numCode: Int
    let charCode: String
    let nominal: Int
    let name: String
    let value: String
    
    init(with dto: RateDTO) {
        numCode = dto.NumCode
        charCode = dto.CharCode
        nominal = dto.Nominal
        name = dto.Name
        value = dto.Value
    }
}

class RateCell: CommonCell {

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var baseView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.layer.cornerRadius = 16
    }
    
    override func update(with vm: CommonCellVM) {
        guard let vm = vm as? RateCellVM else { return }
        rateLabel.text = vm.value
        nameLabel.text = vm.name
        codeLabel.text = "\(vm.charCode) \(vm.nominal != 1 ? "(\(vm.nominal))" : "")"
        if vm.charCode.first! < "H" && vm.charCode.first! > "A"  {
            rateLabel.textColor = .systemRed
        } else {
            rateLabel.textColor = .systemGreen
        }
    }
}
