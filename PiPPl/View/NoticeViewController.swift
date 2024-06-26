//
//  NoticeViewController.swift
//  PiPPl
//
//  Created by 김민택 on 3/17/24.
//

import UIKit

class NoticeViewController: UICollectionViewController {

    // MARK: - Property

    private enum Section: CaseIterable {
        case noticeList
    }

    private enum NoticeItem: Hashable {
        case title(Notice)
        case content(Notice)
    }

    private let titleCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Notice> { cell, indexPath, item in
        var content = cell.defaultContentConfiguration()
        content.text = item.createDate
        content.textProperties.font = .systemFont(ofSize: 14)
        content.textProperties.color = .gray

        content.secondaryText = item.title
        content.secondaryTextProperties.font = .systemFont(ofSize: 17)

        cell.contentConfiguration = content

        var headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
        headerDisclosureOption.tintColor = .black
        cell.accessories = [.outlineDisclosure(options: headerDisclosureOption)]
    }

    private let contentCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Notice> { cell, indexPath, item in
        var content = cell.defaultContentConfiguration()
        content.text = item.content
        content.textProperties.font = .systemFont(ofSize: 16)
        cell.contentConfiguration = content
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, NoticeItem> = {
        return UICollectionViewDiffableDataSource<Section, NoticeItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .title(let title):
                return collectionView.dequeueConfiguredReusableCell(using: self.titleCellRegistration, for: indexPath, item: title)
            case .content(let content):
                return collectionView.dequeueConfiguredReusableCell(using: self.contentCellRegistration, for: indexPath, item: content)
            }
        }
    }()

    // MARK: - Life Cycle

    init() {
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .plain)))
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = AppText.notice
        NetworkManager.shared.requestData { data in
            NetworkManager.shared.notices = data
        }

        applySnapshot()
    }

    // MARK: - Method

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NoticeItem>()
        snapshot.appendSections(Section.allCases)
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<NoticeItem>()

        for item in NetworkManager.shared.notices.reversed() {
            let noticeTitle = NoticeItem.title(item)
            sectionSnapshot.append([noticeTitle])

            let noticeContent = NoticeItem.content(item)
            sectionSnapshot.append([noticeContent], to: noticeTitle)
        }

        dataSource.apply(snapshot)
        dataSource.apply(sectionSnapshot, to: .noticeList, animatingDifferences: true)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
