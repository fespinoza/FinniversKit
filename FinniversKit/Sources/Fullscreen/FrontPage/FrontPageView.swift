//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public protocol FrontPageViewModel {
    var adRecommedationsGridViewHeaderTitle: String { get }
    var retryButtonTitle: String { get }
    var noRecommendationsText: String { get }
}

public protocol FrontPageViewDelegate: AnyObject {
    func frontPageViewDidSelectRetryButton(_ frontPageView: FrontPageView)
}

public final class FrontPageView: UIView {
    public var model: FrontPageViewModel? {
        didSet {
            headerLabel.text = model?.adRecommedationsGridViewHeaderTitle
            adsRetryView.set(labelText: model?.noRecommendationsText, buttonText: model?.retryButtonTitle)
        }
    }

    public var isRefreshEnabled: Bool {
        get {
            return adRecommendationsGridView.isRefreshEnabled
        }
        set {
            adRecommendationsGridView.isRefreshEnabled = newValue
        }
    }

    private weak var delegate: FrontPageViewDelegate?
    private var didSetupView = false

    // MARK: - Subviews

    private let marketsGridView: MarketsGridView
    private let adRecommendationsGridView: AdRecommendationsGridView
    private lazy var headerView = UIView()

    private lazy var headerLabel: Label = {
        var headerLabel = Label(style: .title3)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        return headerLabel
    }()

    private lazy var adsRetryView: LoadingRetryView = {
        let view = LoadingRetryView()
        view.delegate = self
        return view
    }()

    private lazy var marketsGridViewHeight = self.marketsGridView.heightAnchor.constraint(equalToConstant: 0)

    private var keyValueObservation: NSKeyValueObservation?

    private var boundsForCurrentSubviewSetup = CGRect.zero

    // MARK: - Init

    public convenience init(delegate: FrontPageViewDelegate & MarketsGridViewDelegate & MarketsGridViewDataSource & AdRecommendationsGridViewDelegate, adRecommendationsGridViewDataSource: AdRecommendationsGridViewDataSource) {
        self.init(delegate: delegate, marketsGridViewDelegate: delegate, marketsGridViewDataSource: delegate, adRecommendationsGridViewDelegate: delegate, adRecommendationsGridViewDataSource: adRecommendationsGridViewDataSource)
    }

    public init(delegate: FrontPageViewDelegate, marketsGridViewDelegate: MarketsGridViewDelegate, marketsGridViewDataSource: MarketsGridViewDataSource, adRecommendationsGridViewDelegate: AdRecommendationsGridViewDelegate, adRecommendationsGridViewDataSource: AdRecommendationsGridViewDataSource) {
        marketsGridView = MarketsGridView(delegate: marketsGridViewDelegate, dataSource: marketsGridViewDataSource)
        marketsGridView.translatesAutoresizingMaskIntoConstraints = false

        adRecommendationsGridView = AdRecommendationsGridView(delegate: adRecommendationsGridViewDelegate, dataSource: adRecommendationsGridViewDataSource)
        adRecommendationsGridView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        keyValueObservation?.invalidate()
    }

    // MARK: - Public

    public override func layoutSubviews() {
        super.layoutSubviews()

        if didSetupView == false {
            setup()
            didSetupView = true
        } else if !boundsForCurrentSubviewSetup.equalTo(bounds) {
            setupFrames()
        }
    }

    public func reloadData() {
        marketsGridView.reloadData()
        setupFrames()
        reloadAds()
    }

    public func reloadMarkets() {
        marketsGridView.reloadData()
        setupFrames()
        adRecommendationsGridView.reloadData()
    }

    public func reloadAds() {
        adsRetryView.state = .hidden
        adRecommendationsGridView.reloadData()
    }

    public func updateAd(at index: Int, isFavorite: Bool) {
        adRecommendationsGridView.updateItem(at: index, isFavorite: isFavorite)
    }

    public func showAdsRetryButton() {
        adRecommendationsGridView.endRefreshing()
        adsRetryView.state = .labelAndButton
    }

    public func scrollToTop() {
        adRecommendationsGridView.scrollToTop()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .bgPrimary

        addSubview(adRecommendationsGridView)

        adRecommendationsGridView.collectionView.addSubview(adsRetryView)

        headerView.addSubview(marketsGridView)
        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            marketsGridView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: .spacingM),
            marketsGridView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            marketsGridView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            marketsGridViewHeight,

            headerLabel.topAnchor.constraint(equalTo: marketsGridView.bottomAnchor, constant: .spacingM),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: .spacingM),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -.spacingM),
        ])

        adRecommendationsGridView.fillInSuperview()
        adRecommendationsGridView.headerView = headerView

        setupFrames()
    }

    private func setupFrames() {
        let headerTopSpacing: CGFloat = .spacingM
        let headerBottomSpacing: CGFloat = .spacingS
        let labelHeight = headerLabel.intrinsicContentSize.height + .spacingM
        let marketGridViewHeight = marketsGridView.calculateSize(constrainedTo: bounds.size.width).height + .spacingXS
        let height = headerTopSpacing + labelHeight + marketGridViewHeight + headerBottomSpacing

        marketsGridViewHeight.constant = marketGridViewHeight
        headerView.frame.size.height = height
        adsRetryView.frame.origin = CGPoint(x: 0, y: headerView.frame.height + .spacingXXL)
        adsRetryView.frame.size = CGSize(width: bounds.width, height: 200)
        boundsForCurrentSubviewSetup = bounds
        adRecommendationsGridView.invalidateLayout()
    }
}

// MARK: - LoadingRetryViewDelegate

extension FrontPageView: LoadingRetryViewDelegate {
    func loadingRetryViewDidSelectButton(_ view: LoadingRetryView) {
        adsRetryView.state = .loading
        delegate?.frontPageViewDidSelectRetryButton(self)
    }
}
