//
//  FullNewsController.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit

class FullNewsController: UITableViewController {

    var vms: [CommonCellVM] = [SpaceCellVM(height: 240), NewsTitleCellVM(title: "Утрений фон", date: Date())]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "RateCell", bundle: nil), forCellReuseIdentifier: "RateCell")
        tableView.register(UINib(nibName: "SpaceCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableView.register(UINib(nibName: "NewsTitleCell", bundle: nil), forCellReuseIdentifier: "NewsTitleCell")
        tableView.register(UINib(nibName: "TitleImageCellVM", bundle: nil), forCellReuseIdentifier: "TitleImageCellVM")
        tableView.register(UINib(nibName: "NewsBodyCell", bundle: nil), forCellReuseIdentifier: "NewsBodyCell")

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = vms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: vm.classId) as! CommonCell
        cell.update(with: vm)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vms.count
    }
    
}
