//
//  CustomerServiceMailView.swift
//  PiPPl
//
//  Created by 김민택 on 4/23/25.
//

import MessageUI
import SwiftUI

struct CustomerServiceMailView: UIViewControllerRepresentable {
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: CustomerServiceMailView

        init(_ parent: CustomerServiceMailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
            controller.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let customerServiceMail = MFMailComposeViewController()
        customerServiceMail.mailComposeDelegate = context.coordinator
        customerServiceMail.setToRecipients(["meenu170808@gmail.com"])
        customerServiceMail.setSubject("[PiPPl] \(AppText.mailTitle)")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let customerServiceBody = """

        ----------------------------------------

        - \(AppText.name):
        - \(AppText.mail):
        - \(AppText.date): \(Date())
        - \(AppText.device): \(UIDevice.current.model)
        - \(AppText.os): \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        - \(AppText.appVersion)): \(version)
        - \(AppText.mailBody):

        ----------------------------------------

        \(AppText.mailComment)

        """
        customerServiceMail.setMessageBody(customerServiceBody, isHTML: false)
        return customerServiceMail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
