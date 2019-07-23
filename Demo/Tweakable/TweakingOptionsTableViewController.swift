import FinniversKit

protocol TweakingOptionsTableViewControllerDelegate: AnyObject {
    func tweakingOptionsTableViewControllerDidDismiss(_ tweakingOptionsTableViewController: TweakingOptionsTableViewController)
}

class TweakingOptionsTableViewController: UIViewController {
    weak var delegate: TweakingOptionsTableViewControllerDelegate?
    private let options: [TweakingOption]

    private lazy var tableView: UITableView = {
        let view = UITableView(withAutoLayout: true)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    init(options: [TweakingOption]) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setup() {
        view.addSubview(tableView)
        tableView.fillInSuperview()
        tableView.register(TweakingOptionCell.self)
    }
}

// MARK: - UITableViewDataSource

extension TweakingOptionsTableViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(TweakingOptionCell.self, for: indexPath)
        let option = options[indexPath.row]
        cell.configure(withOption: option)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TweakingOptionsTableViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = options[indexPath.row]
        option.action()
        delegate?.tweakingOptionsTableViewControllerDidDismiss(self)
    }
}