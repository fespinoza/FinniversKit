//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import SwiftUI
@testable import FinnUI

public enum SwiftUIDemoViews: String, CaseIterable {
    case settings
    case basicCellVariations

    public static var items: [SwiftUIDemoViews] {
        if #available(iOS 13.0.0, *) {
            return allCases.sorted { $0.rawValue < $1.rawValue }
        } else {
            return []
        }
    }

    public var viewController: UIViewController {
        if #available(iOS 13.0.0, *) {
            return PreviewController(hostingController: hostingController)
        } else {
            return DemoViewController<UIView>()
        }
    }

    @available(iOS 13.0, *)
    private var hostingController: UIViewController {
        switch self {
        case .settings:
            return UIHostingController(rootView: SettingsView_Previews.previews)
        case .basicCellVariations:
            return UIHostingController(rootView: BasicListCell_Previews.previews)
        }
    }
}

private final class PreviewController: DemoViewController<UIView> {
    var hostingController: UIViewController

    init(hostingController: UIViewController) {
        self.hostingController = hostingController
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let childViewController = childViewController else {
            return
        }

        childViewController.addChild(hostingController)
        hostingController.view.frame = childViewController.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: childViewController)
    }
}