//
//  ViewListViewController.swift
//  PiPPl
//
//  Created by 김민택 on 3/22/24.
//

import UIKit

class ViewListViewController: UITableViewController {

    private var dataSource: UITableViewDiffableDataSource<Int, String>?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")

        dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) { (tableView, indexPath, text) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
            var cellConfig = UIListContentConfiguration.cell()
            cellConfig.text = text
            cell.contentConfiguration = cellConfig
            return cell
        }

        tableView.dataSource = dataSource

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()

        snapshot.appendSections([0])
        snapshot.appendItems(["로컬 플레이", "네트워크 플레이", "앱 정보"])
        dataSource?.apply(snapshot)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            navigationController?.showDetailViewController(LocalVideoGalleryViewController(), sender: nil)
            break
        case [0, 1]:
            navigationController?.showDetailViewController(NetworkPlayerViewController(), sender: nil)
        case [0, 2]:
            navigationController?.showDetailViewController(AppInfoViewController(), sender: nil)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
