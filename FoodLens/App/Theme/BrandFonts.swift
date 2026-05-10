import SwiftUI
import UIKit
import CoreText

enum BrandFontRegistrar {
    static func registerCustomFonts() {
        let names = [
            "MomoTrustSans-Light",
            "MomoTrustSans-Regular",
            "MomoTrustSans-Medium",
            "MomoTrustSans-SemiBold",
            "MomoTrustSans-Bold",
            "MomoTrustSans-ExtraBold",
            "MomoTrustDisplay-Regular",
            "MomoSignature-Regular"
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("⚠️ Missing font file: \(name).ttf")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                if let cfError = error?.takeRetainedValue() {
                    let code = CFErrorGetCode(cfError)
                    // 105 = kCTFontManagerErrorAlreadyRegistered (safe to ignore)
                    if code != 105 {
                        print("⚠️ Failed to register \(name): \(cfError)")
                    }
                }
            }
        }
    }
}

extension Font {
    static func momoSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font(uiMomoSans(size: size, weight: weight))
    }

    static func momoDisplay(_ size: CGFloat) -> Font {
        Font(uiCustomFont(name: "MomoTrustDisplay-Regular", size: size))
    }

    static func momoSignature(_ size: CGFloat) -> Font {
        Font(uiCustomFont(name: "MomoSignature-Regular", size: size))
    }

    static func uiMomoSans(size: CGFloat, weight: Font.Weight = .regular) -> UIFont {
        uiCustomFont(name: momoSansPostScriptName(for: weight), size: size)
    }

    private static func uiCustomFont(name: String, size: CGFloat) -> UIFont {
        // SFNTLayoutTypes constants (not bridged to Swift):
        //   kLigaturesType = 1
        //     kCommonLigaturesOnSelector = 2
        //     kDiscretionaryLigaturesOnSelector = 4
        //   kContextualAlternatesType = 36
        //     kContextualAlternatesOnSelector = 0
        let baseFont = UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
        let featureSettings: [[UIFontDescriptor.FeatureKey: Any]] = [
            [.type: 1, .selector: 2],   // common ligatures on (liga)
            [.type: 1, .selector: 4],   // discretionary ligatures on (dlig)
            [.type: 36, .selector: 0]   // contextual alternates on (calt)
        ]
        let descriptor = baseFont.fontDescriptor.addingAttributes([
            .featureSettings: featureSettings
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func momoSansPostScriptName(for weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight, .thin, .light: "MomoTrustSans-Light"
        case .medium:                    "MomoTrustSans-Medium"
        case .semibold:                  "MomoTrustSans-SemiBold"
        case .bold:                      "MomoTrustSans-Bold"
        case .heavy, .black:             "MomoTrustSans-ExtraBold"
        default:                         "MomoTrustSans-Regular"
        }
    }
}

extension Font {
    static let brandLargeTitle  = Font.momoSans(34, weight: .bold)
    static let brandTitle       = Font.momoSans(28, weight: .bold)
    static let brandTitle2      = Font.momoSans(22, weight: .semibold)
    static let brandTitle3      = Font.momoSans(20, weight: .semibold)
    static let brandHeadline    = Font.momoSans(17, weight: .semibold)
    static let brandBody        = Font.momoSans(17)
    static let brandBodyEmph    = Font.momoSans(17, weight: .semibold)
    static let brandCallout     = Font.momoSans(16)
    static let brandSubheadline = Font.momoSans(15)
    static let brandFootnote    = Font.momoSans(13)
    static let brandCaption     = Font.momoSans(12)
    static let brandCaption2    = Font.momoSans(11)

    static let brandHeroNumber  = Font.momoDisplay(96)
    static let brandBigNumber   = Font.momoDisplay(48)
}
