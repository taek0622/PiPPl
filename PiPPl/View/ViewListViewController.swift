//
//  ViewListViewController.swift
//  PiPPl
//
//  Created by 김민택 on 3/22/24.
//

import UIKit

class ViewListViewController: UITableViewController {

    private var dataSource: UITableViewDiffableDataSource<Int, String>?
    private let localPlayerView = UINavigationController(rootViewController: LocalVideoGalleryViewController())
    private let networkPlayerView = UINavigationController(rootViewController: NetworkPlayerViewController())
    private let appInfoView = UINavigationController(rootViewController: AppInfoViewController())

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
        snapshot.appendItems([AppText.localVideo.localized(), AppText.networkVideo.localized(), AppText.appInfo.localized()])
        dataSource?.apply(snapshot)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            splitViewController?.setViewController(localPlayerView, for: .secondary)
            break
        case [0, 1]:
            splitViewController?.setViewController(networkPlayerView, for: .secondary)
        case [0, 2]:
            splitViewController?.setViewController(appInfoView, for: .secondary)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
