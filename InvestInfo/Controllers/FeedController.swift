//
//  FeedController.swift
//  InvestInfo
//
//  Created by Иван Трофимов on 14.09.2022.
//

import UIKit
import Alamofire

class FeedController: UITableViewController {

    var vms: [CommonCellVM] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        tableView.register(UINib(nibName: "SpaceCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        
        fetchData()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if vms[indexPath.row] is NewsCellVM {
            guard let nextVC = storyboard?.instantiateViewController(withIdentifier: "FullNewsController") as? FullNewsController else { return }
            nextVC.viewModel = vms[indexPath.row] as? NewsCellVM
            present(nextVC, animated: true)
        }
    }

    func fetchData() {
        AF.request(Constants.baseHost).responseDecodable(of: NewsListDTO.self) { response in
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

