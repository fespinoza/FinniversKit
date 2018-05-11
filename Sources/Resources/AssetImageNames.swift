//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

// Generated by generate_image_assets_symbols as a "Run Script" Build Phase
// WARNING: This file is autogenerated, do not modify by hand

import UIKit

extension UIImage {
    convenience init(named imageAsset: ImageAsset, in bundle: Bundle? = .finniversKit, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.init(named: imageAsset.rawValue, in: bundle, compatibleWith: traitCollection)!
    }
}

enum ImageAsset: String {
    case noImage = "NoImage"
    case spidLogo = "SpidLogo"
    case consentTransparencyImage
    case consentViewImage1
    case error
    case important
    case remove
    case success
    case view
    case webview
}