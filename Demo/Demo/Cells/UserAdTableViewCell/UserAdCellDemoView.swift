//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import Foundation
import FinniversKit

class UserAdCellDemoView: UIView, Tweakable {

    lazy var tweakingOptions: [TweakingOption] = [
        TweakingOption(title: "Default") { self.style = .default },
        TweakingOption(title: "Compact") { self.style = .compressed },
    ]

    private var style: UserAdTableViewCell.Style = .default {
        didSet {
            tableView.reloadData()
        }
    }

    private let viewModels: [UserAdCellViewModel] = UserAdsFactory.createAds()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(withAutoLayout: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserAdTableViewCell.self)
        tableView.separatorInset = .leadingInset(frame.width)
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(tableView)
        tableView.fillInSuperview()
    }

}

// MARK: - UITableViewDelegate

extension UserAdCellDemoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension UserAdCellDemoView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UserAdTableViewCell.self, for: indexPath)
        cell.configure(with: style, model: viewModels[indexPath.row])
        cell.remoteImageViewDataSource = DemoRemoteImageViewDataSource.shared
        cell.loadingColor = .toothPaste
        cell.accessoryType = indexPath.row == viewModels.count - 1 ? .disclosureIndicator : .none

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ImageLoading {
            cell.loadImage()
        }
    }
}
