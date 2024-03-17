//
//  AppInfoViewController.swift
//  PiPPl
//
//  Created by 김민택 on 1/23/24.
//

import MessageUI
import SafariServices
import UIKit

class AppInfoViewController: UIViewController {

    // MARK: - Property

    private lazy var dataSource: UICollectionViewDiffableDataSource<String, String>! = nil

    // MARK: - View

    private lazy var collectionView: UICollectionView! = nil

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "앱 정보"
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        configureDataSource()
    }

    // MARK: - Method

    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() { index, environment in
            let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            return section
        }

        return layout
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item

            if item == "버전 정보" {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                content.secondaryText = version
                content.secondaryTextProperties.font = .systemFont(ofSize: 16)
                content.secondaryTextProperties.color = .gray
            }

            content.prefersSideBySideTextAndSecondaryText = true
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<String, String>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        var snapshot = NSDiffableDataSourceSnapshot<String, String>()
        snapshot.appendSections(["앱 정보"])
        snapshot.appendItems(["공지사항", "개발자 정보", "고객 문의", "버전 정보"], toSection: "앱 정보")
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

extension AppInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            navigationController?.pushViewController(NoticeViewController(), animated: true)
        case [0, 1]:
            if let url = URL(string: "https://github.com/taek0622") {
                let developerInfo = SFSafariViewController(url: url)
                present(developerInfo, animated: true)
            }
        case [0, 2]:
            openCustomerServiceCenter()
        case [0, 3]:
            // 버전정보
            break
        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension AppInfoViewController: MFMailComposeViewControllerDelegate {
    func openCustomerServiceCenter() {
        if !MFMailComposeViewController.canSendMail() {
            let alertViewController = UIAlertController(title: "메일 기능 사용 불가", message: "앱에서 메일을 보낼 수 없습니다. 기기의 상태를 확인한 후에 다시 이용해주세요.\n지속적으로 오류가 발생하는 경우 meenu170808@gmail.com으로 별도의 메일 발송 부탁드립니다.", preferredStyle: .alert)
            present(alertViewController, animated: true)
        }

        let customerServiceMail = MFMailComposeViewController()
        customerServiceMail.mailComposeDelegate = self
        customerServiceMail.setToRecipients(["meenu170808@gmail.com"])
        customerServiceMail.setSubject("[PiPPl] 문의 사항")
        let customerServiceBody = """

        ----------------------------------------

        - 성함:
        - 연락처(전화번호/이메일):
        - 문의 날짜: \(Date())
        - 디바이스 종류:
        - 문의 내용:

        ----------------------------------------

        문의 내용을 작성해주세요.

        """
        customerServiceMail.setMessageBody(customerServiceBody, isHTML: false)
        present(customerServiceMail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
