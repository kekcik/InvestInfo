//
//  FeedController.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit
import Alamofire

final class FeedController: UITableViewController {
    private var vms: [CommonCellVM] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tableView.register(UINib(nibName: "SpaceCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = SettingsStorageService.shared.getValue(.createNews) ?
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNews)) : nil
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = vms[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: vm.classId) as? CommonCell
        else { return UITableViewCell() }
        cell.update(with: vm)
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vms.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let viewModel = vms[indexPath.row] as? NewsCellVM,
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "FullNewsController") as? FullNewsController
        else { return }
        nextVC.viewModel = viewModel
        present(nextVC, animated: true)
    }
}

// MARK: - Helper
private extension FeedController {
    @objc func createNews() {
        present(AddNewsController(), animated: true)
    }
    
    func fetchData() {
        AF.request(Constants.baseHost + "/feed").responseDecodable(of: NewsListDTO.self) { response in
            debugPrint("Response: \(response)")
            switch response.result {
            case .success(let data):
                print(data.news)
                self.vms = []
                data.news.forEach({ self.vms += [NewsCellVM(with: $0), SpaceCellVM(height: 24)] })
                self.tableView.reloadData()
            default: break
            }
        }
    }
}
