//
//  Copyright © 2019 FINN AS. All rights reserved.
//

import UIKit

class LoginEntryDialogueView: UIView {
    // MARK: - Internal properties

    var model: LoginEntryViewModel? {
        didSet {
            titleLabel.text = model?.title
            detailLabel.text = model?.detail
            loginButton.setTitle(model?.loginButtonTitle, for: .normal)
            registerButton.setTitle(model?.registerButtonTitle, for: .normal)
        }
    }
    weak var delegate: LoginEntryViewDelegate?

    // MARK: - Private properties

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.image = UIImage(named: .finnLogo)
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        // overriding the font to get the title2 strong without affecting
        // the design system itself for now
        let title2StrongFont = UIFont(name: FontType.medium.rawValue, size: 28.0)!
            .scaledFont(forTextStyle: .title2)

        let label = Label(style: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = title2StrongFont
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = Label(style: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var loginButton: UIButton = {
        let button = Button(style: .callToAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLoginButtonTap), for: .touchUpInside)

        return button
    }()

    private lazy var registerButton: UIButton = {
        let button = Button(style: .flat)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRegisterButtonTap), for: .touchUpInside)
        button.titleLabel?.numberOfLines = 0

        return button
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Private methods

    private func setup() {
        layer.cornerRadius = 33
        layoutMargins = UIEdgeInsets(all: .largeSpacing)

        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(loginButton)
        addSubview(registerButton)

        let margin = layoutMarginsGuide

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: margin.topAnchor, constant: .largeSpacing),
            logoImageView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: .largeSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .mediumSpacing),
            detailLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: .mediumSpacing),
            detailLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: -.mediumSpacing),

            loginButton.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: .largeSpacing),
            loginButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor),

            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: .mediumLargeSpacing),
            registerButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            registerButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor),
        ])
    }

    @objc private func handleLoginButtonTap() {
        delegate?.loginEntryViewDidSelectLoginButton()
    }

    @objc private func handleRegisterButtonTap() {
        delegate?.loginEntryViewDidSelectRegisterButton()
    }
}