//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol MotorTransactionStepContentViewDelegate: AnyObject {

    //swiftlint:disable:next function_parameter_count
    func motorTransactionStepContentViewDidTapButton(
        _ view: MotorTransactionStepContentView,
        inStep step: Int,
        inContentView kind: MotorTransactionStepContentView.Kind,
        withButtonTag tag: MotorTransactionButton.Tag,
        withAction action: MotorTransactionButton.Action,
        withUrl urlString: String?,
        withFallbackUrl fallbackUrlString: String?
    )
}

public class MotorTransactionStepContentView: UIView {

    // MARK: - Public properties

    public weak var delegate: MotorTransactionStepContentViewDelegate?

    public enum Kind {
        case main
        case detail
    }

    // MARK: - Private properties

    private static let defaultImageSize = CGFloat(64)

    private var step: Int
    private var currentStep: Int
    private var kind: MotorTransactionStepContentView.Kind
    private var state: MotorTransactionStepViewState
    private var model: MotorTransactionStepContentViewModel

    private var nativeButtonModel: MotorTransactionButtonViewModel?
    private var primaryButtonModel: MotorTransactionButtonViewModel?

    private var verticalStackViewLeadingAnchor: NSLayoutConstraint?
    private var verticalStackViewTrailingAnchor: NSLayoutConstraint?
    private var verticalStackViewTopAnchor: NSLayoutConstraint?

    private var bottomAnchorConstraint: NSLayoutConstraint?

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView(withAutoLayout: true)
        view.backgroundColor = .clear
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    private lazy var titleView: UITextView = {
        let view = UITextView(withAutoLayout: true)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.isEditable = false
        view.adjustsFontForContentSizeCategory = true
        view.textContainerInset = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        view.textContainer.widthTracksTextView = true
        view.textContainer.heightTracksTextView = true
        return view
    }()

    private lazy var bodyView: UITextView = {
        let view = UITextView(withAutoLayout: true)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.isEditable = false
        view.adjustsFontForContentSizeCategory = true
        view.textContainerInset = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        view.textContainer.widthTracksTextView = true
        view.textContainer.heightTracksTextView = true
        return view
    }()

    private lazy var remoteImageView: RemoteImageView = {
        let remoteImageView = RemoteImageView(withAutoLayout: true)
        remoteImageView.backgroundColor = .clear
        remoteImageView.layer.cornerRadius = MotorTransactionStepContentView.defaultImageSize / 2
        remoteImageView.clipsToBounds = true
        remoteImageView.contentMode = .scaleAspectFit
        return remoteImageView
    }()

    // MARK: - Init

    public init(
        step: Int,
        currentStep: Int,
        kind: MotorTransactionStepContentView.Kind,
        state: MotorTransactionStepViewState,
        model: MotorTransactionStepContentViewModel,
        withAutoLayout autoLayout: Bool = false
    ) {
        self.step = step
        self.currentStep = currentStep
        self.kind = kind
        self.state = state
        self.model = model

        self.nativeButtonModel = model.nativeButton ?? nil
        self.primaryButtonModel = model.primaryButton ?? nil

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = !autoLayout

        titleView.font = model.titleFont
        titleView.textColor = model.titleTextColor

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

private extension MotorTransactionStepContentView {
    private func setup() {
        backgroundColor = .clear

        addSubview(verticalStackView)
        setupStackViewConstraints()

        if let imageUrl = model.imageUrl {
            setupContentViewWithImage(model.title, model.nativeBody, model.body, imageUrl)
        } else if let title = model.title {
            titleView.text = title

            verticalStackView.addArrangedSubview(titleView)
            verticalStackView.setCustomSpacing(.spacingS, after: titleView)

            setupBodyView(model.nativeBody, model.body)
        } else {
            setupBodyView(model.nativeBody, model.body)
        }

        // nativeButton must precede primaryButton hence ordering
        setupButton(model.nativeButton, tag: .native)
        setupButton(model.primaryButton, tag: .primary)

        bottomAnchorConstraint?.isActive = true
    }

    private func setupStackViewConstraints() {
        switch state {
        case .notStarted:
            verticalStackViewLeadingAnchor = verticalStackView.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .spacingXS)
            verticalStackViewTrailingAnchor = verticalStackView.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.spacingS)
            verticalStackViewTopAnchor = verticalStackView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor)
        case .active:
            verticalStackViewLeadingAnchor = verticalStackView.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .spacingM)
            verticalStackViewTrailingAnchor = verticalStackView.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.spacingS)
            verticalStackViewTopAnchor = verticalStackView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor, constant: .spacingM)
        case .completed:
            if step == currentStep {
                verticalStackViewLeadingAnchor = verticalStackView.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .spacingM)
                verticalStackViewTrailingAnchor = verticalStackView.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.spacingS)
                verticalStackViewTopAnchor = verticalStackView.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor, constant: .spacingM)
            } else {
                verticalStackViewLeadingAnchor = verticalStackView.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .spacingXS)
                verticalStackViewTrailingAnchor = verticalStackView.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.spacingS)
                verticalStackViewTopAnchor = verticalStackView.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor)
            }
        }

        NSLayoutConstraint.activate([
            verticalStackViewLeadingAnchor!,
            verticalStackViewTrailingAnchor!,
            verticalStackViewTopAnchor!,
        ])
	}

    private func setupContentViewWithImage(_ title: String?, _ nativeBody: NSAttributedString?, _ body: NSAttributedString?, _ imageUrl: URL) {
        let horizontalStackView = UIStackView(withAutoLayout: true)
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        horizontalStackView.alignment = .top
        horizontalStackView.backgroundColor = .clear

        let contentStackView = UIStackView(withAutoLayout: true)
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .leading
        contentStackView.backgroundColor = .clear

        if let title = title {
            titleView.text = title
            contentStackView.addArrangedSubview(titleView)
        }

        let body = nativeBody != nil ? nativeBody : body
        if let body = body {
            bodyView.attributedText = body
            contentStackView.addArrangedSubview(bodyView)
        }

        remoteImageView.loadImage(
            for: imageUrl.absoluteString,
            imageWidth: MotorTransactionStepContentView.defaultImageSize,
            loadingColor: .iconSecondary,
            fallbackImage: UIImage(named: .noImage)
        )

        horizontalStackView.addArrangedSubviews([remoteImageView, contentStackView])

        verticalStackView.addArrangedSubview(horizontalStackView)
        verticalStackView.setCustomSpacing(.spacingS, after: horizontalStackView)

        NSLayoutConstraint.activate([
            remoteImageView.heightAnchor.constraint(equalToConstant: MotorTransactionStepContentView.defaultImageSize),
            remoteImageView.widthAnchor.constraint(equalToConstant: MotorTransactionStepContentView.defaultImageSize)
        ])

        bottomAnchorConstraint = bottomAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: .spacingM)
    }

    private func setupBodyView(_ nativeBody: NSAttributedString?, _ body: NSAttributedString?) {
        let text = nativeBody != nil ? nativeBody : body
        guard text != nil else { return }

        bodyView.attributedText = text

        verticalStackView.addArrangedSubview(bodyView)
        verticalStackView.setCustomSpacing(.spacingS, after: bodyView)

        bottomAnchorConstraint = bottomAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: .spacingM)
    }

    private func setupButton(_ buttonModel: MotorTransactionButtonViewModel?, tag: MotorTransactionButton.Tag) {
        if let buttonModel = buttonModel {
            let buttonText = buttonModel.text
            let buttonStyle = MotorTransactionButton(rawValue: buttonModel.style ?? "").style
            let buttonAction = MotorTransactionButton.Action(rawValue: buttonModel.action ?? "")

            let button = Button(style: buttonStyle, withAutoLayout: true)
            button.setTitle(buttonText, for: .normal)
            button.tag = tag.rawValue
            button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)

            verticalStackView.addArrangedSubview(button)
            verticalStackView.setCustomSpacing(.spacingM, after: button)

            switch buttonAction {
            case .seeAd:
                button.contentHorizontalAlignment = .leading
                button.contentEdgeInsets = .leadingInset(.spacingS)
            case .republishAd, .purchaseInsurance:
                break
            default:
                addWebViewIconToButton(button)
            }

            switch tag {
            case .native:
                bottomAnchorConstraint = bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingS)
            case .primary:
                bottomAnchorConstraint = bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .spacingM)
            }
        }
    }

    private func addWebViewIconToButton(_ button: Button) {
        let image = UIImage(named: .webview).withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = button.titleLabel?.textColor ?? .bgPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let imageWidth: CGFloat = .spacingM
        var leadingTitleInset = CGFloat.zero
        var trailingAnchorConstant = CGFloat.zero

        if state == .completed {
            button.contentHorizontalAlignment = .leading
            leadingTitleInset = -8
            trailingAnchorConstant = -24
        } else {
            leadingTitleInset = button.titleEdgeInsets.leading + imageWidth - 20
            trailingAnchorConstant = -20
        }

        button.titleEdgeInsets = UIEdgeInsets(
            top: button.titleEdgeInsets.top,
            leading: leadingTitleInset,
            bottom: button.titleEdgeInsets.bottom,
            trailing: button.titleEdgeInsets.trailing + imageWidth + .spacingS
        )

        addSubview(imageView)

        let buttonWidth = button.widthAnchor.constraint(
            greaterThanOrEqualToConstant: button.intrinsicContentSize.width + imageWidth + .spacingS
        )
        buttonWidth.priority = .required

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: trailingAnchorConstant),

            buttonWidth
        ])
    }
}

// MARK: - Selectors

private extension MotorTransactionStepContentView {
    @objc func handleButtonTap(_ sender: Button) {
        guard let tag = MotorTransactionButton.Tag(rawValue: sender.tag) else { return }
        var model: MotorTransactionButtonViewModel?

        switch tag {
        case .native:
            model = nativeButtonModel
        case .primary:
            model = primaryButtonModel
        }

        let action = MotorTransactionButton.Action(rawValue: model?.action ?? "unknown")
        let urlString = model?.url
        let fallbackUrlString = model?.fallbackUrl

        delegate?.motorTransactionStepContentViewDidTapButton(
            self,
            inStep: step,
            inContentView: kind,
            withButtonTag: tag,
            withAction: action,
            withUrl: urlString,
            withFallbackUrl: fallbackUrlString
        )
    }
}
