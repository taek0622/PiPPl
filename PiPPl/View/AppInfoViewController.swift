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
        navigationItem.title = AppText.appInfo.localized()
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

            if item == AppText.versionInfo.localized() {
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
        snapshot.appendItems([AppText.notice.localized(), AppText.developerInfo.localized(), AppText.customerService.localized(), AppText.license.localized(), AppText.versionInfo.localized()], toSection: "앱 정보")
        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

extension AppInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            navigationController?.pushViewController(NoticeViewController(), animated: true)
        case [0, 1]:
            guard let url = URL(string: "https://github.com/taek0622") else { return }
            let developerInfo = SFSafariViewController(url: url)
            present(developerInfo, animated: true)
        case [0, 2]:
            openCustomerServiceCenter()
        case [0, 3]:
            guard let url = URL(string: "https://pippl.notion.site/e318bd246e894b348ece6387e68270de") else { return }
            let licenseInfo = SFSafariViewController(url: url)
            present(licenseInfo, animated: true)
        case [0, 4]:
            Task {
                switch await AppVersionManager.shared.checkNewUpdate() {
                case true:
                    guard let filePath = Bundle.main.path(forResource: "Properties", ofType: "plist"),
                          let property = NSDictionary(contentsOfFile: filePath),
                          let iTunesID = property["iTunesID"] as? String
                    else { return }

                    let appStoreOpenURL = "itms-apps://itunes.apple.com/app/apple-store/\(iTunesID)"
                    let alert = UIAlertController(title: "구버전 알림", message: "새로운 버전의 앱이 출시 되었습니다.\n업데이트 이후 사용해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "업데이트 하기", style: .default, handler: { action in
                        guard let url = URL(string: appStoreOpenURL) else { return }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }))
                    present(alert, animated: true)
                case false:
                    let alert = UIAlertController(title: "최신 버전", message: "앱이 최신 버전입니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    present(alert, animated: true)
                }
            }
        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension AppInfoViewController: MFMailComposeViewControllerDelegate {
    func openCustomerServiceCenter() {
        if !MFMailComposeViewController.canSendMail() {
            let alertViewController = UIAlertController(title: AppText.cantSendMailAlertTitle.localized(), message: AppText.cantSendMailAlertBody.localized(), preferredStyle: .alert)
            present(alertViewController, animated: true)
        }

        let customerServiceMail = MFMailComposeViewController()
        customerServiceMail.mailComposeDelegate = self
        customerServiceMail.setToRecipients(["meenu170808@gmail.com"])
        customerServiceMail.setSubject("[PiPPl] \(AppText.mailTitle.localized())")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let customerServiceBody = """

        ----------------------------------------

        - \(AppText.name.localized()):
        - \(AppText.mail.localized()):
        - \(AppText.date.localized()): \(Date())
        - \(AppText.device.localized()): \(UIDevice.current.model)
        - \(AppText.os.localized()): \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        - \(AppText.appVersion.localized()): \(version)
        - \(AppText.mailBody.localized()):

        ----------------------------------------

        \(AppText.mailComment.localized())

        """
        customerServiceMail.setMessageBody(customerServiceBody, isHTML: false)
        present(customerServiceMail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
