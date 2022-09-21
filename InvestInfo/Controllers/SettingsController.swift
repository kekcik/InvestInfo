//
//  SettingsController.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 20.09.2022.
//

import UIKit

final class SettingsController: UITableViewController {
    private var vms: [CommonCellVM] = []
    
    enum CellName: String, Equatable { case noOne, pushNotifications, createNews }
    struct SettingsCellName: CommonCellNameProtocol { var name: CellName = .noOne }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.separatorStyle = .none
        tableView.register(SwitcherCell.self, forCellReuseIdentifier: "SwitcherCell")
        [ "SpaceCell" ].forEach {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        createData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = vms[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: vm.classId) as? CommonCell
        else { return UITableViewCell() }
        cell.update(with: vm)
        guard let cell = cell as? CommonCellOutProtocol else { return cell }
        cell.parentViewController = self
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vms.count
    }
}

// MARK: - SwitcherProtocol
extension SettingsController: SwitcherProtocol {
    func switcherChange(state: Bool, name: CommonCellNameProtocol) {
        guard let localName = (name as? SettingsCellName)?.name else { return }
        //TODO: Надо менять состояния свитчеров в модели
        switch localName {
        case .pushNotifications: break
        case .createNews: break
        default: break
        }
    }
}

// MARK: - Helper
private extension SettingsController {
    func createData() {
        vms = [
            SwitcherCellVM(cellName: SettingsCellName(name: .pushNotifications), text: "Push-уведомления", isOn: true),
            SpaceCellVM(height: 20),
            SwitcherCellVM(cellName: SettingsCellName(name: .createNews), text: "Создание новостей", isOn: false)
        ]
    }
}
