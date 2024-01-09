//
//  FontExtensions.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/6/24.
//

import SwiftUI

/*
 
 Academy Engraved LET
    AcademyEngravedLetPlain
 Al Nile
    AlNile
    AlNile-Bold
 American Typewriter
    AmericanTypewriter
    AmericanTypewriter-Bold
    AmericanTypewriter-Condensed
    AmericanTypewriter-CondensedBold
    AmericanTypewriter-CondensedLight
    AmericanTypewriter-Light
    AmericanTypewriter-Semibold
 Apple Color Emoji
    AppleColorEmoji
 Apple SD Gothic Neo
    AppleSDGothicNeo-Bold
    AppleSDGothicNeo-Light
    AppleSDGothicNeo-Medium
    AppleSDGothicNeo-Regular
    AppleSDGothicNeo-SemiBold
    AppleSDGothicNeo-Thin
    AppleSDGothicNeo-UltraLight
 Apple Symbols
    AppleSymbols
 Arial
    Arial-BoldItalicMT
    Arial-BoldMT
    Arial-ItalicMT
    ArialMT
 Arial Hebrew
    ArialHebrew
    ArialHebrew-Bold
    ArialHebrew-Light
 Arial Rounded MT Bold
    ArialRoundedMTBold
 Avenir
    Avenir-Black
    Avenir-BlackOblique
    Avenir-Book
    Avenir-BookOblique
    Avenir-Heavy
    Avenir-HeavyOblique
    Avenir-Light
    Avenir-LightOblique
    Avenir-Medium
    Avenir-MediumOblique
    Avenir-Oblique
    Avenir-Roman
 Avenir Next
    AvenirNext-Bold
    AvenirNext-BoldItalic
    AvenirNext-DemiBold
    AvenirNext-DemiBoldItalic
    AvenirNext-Heavy
    AvenirNext-HeavyItalic
    AvenirNext-Italic
    AvenirNext-Medium
    AvenirNext-MediumItalic
    AvenirNext-Regular
    AvenirNext-UltraLight
    AvenirNext-UltraLightItalic
 Avenir Next Condensed
    AvenirNextCondensed-Bold
    AvenirNextCondensed-BoldItalic
    AvenirNextCondensed-DemiBold
    AvenirNextCondensed-DemiBoldItalic
    AvenirNextCondensed-Heavy
    AvenirNextCondensed-HeavyItalic
    AvenirNextCondensed-Italic
    AvenirNextCondensed-Medium
    AvenirNextCondensed-MediumItalic
    AvenirNextCondensed-Regular
    AvenirNextCondensed-UltraLight
    AvenirNextCondensed-UltraLightItalic
 Baskerville
    Baskerville
    Baskerville-Bold
    Baskerville-BoldItalic
    Baskerville-Italic
    Baskerville-SemiBold
    Baskerville-SemiBoldItalic
 Bodoni 72
    BodoniSvtyTwoITCTT-Bold
    BodoniSvtyTwoITCTT-Book
    BodoniSvtyTwoITCTT-BookIta
 Bodoni 72 Oldstyle
    BodoniSvtyTwoOSITCTT-Bold
    BodoniSvtyTwoOSITCTT-Book
    BodoniSvtyTwoOSITCTT-BookIt
 Bodoni 72 Smallcaps
    BodoniSvtyTwoSCITCTT-Book
 Bodoni Ornaments
    BodoniOrnamentsITCTT
 Bradley Hand
    BradleyHandITCTT-Bold
 Chalkboard SE
    ChalkboardSE-Bold
    ChalkboardSE-Light
    ChalkboardSE-Regular
 Chalkduster
    Chalkduster
 Charter
    Charter-Black
    Charter-BlackItalic
    Charter-Bold
    Charter-BoldItalic
    Charter-Italic
    Charter-Roman
 Cochin
    Cochin
    Cochin-Bold
    Cochin-BoldItalic
    Cochin-Italic
 Copperplate
    Copperplate
    Copperplate-Bold
    Copperplate-Light
 Courier New
    CourierNewPS-BoldItalicMT
    CourierNewPS-BoldMT
    CourierNewPS-ItalicMT
    CourierNewPSMT
 DIN Alternate
    DINAlternate-Bold
 DIN Condensed
    DINCondensed-Bold
 Damascus
    Damascus
    DamascusBold
    DamascusLight
    DamascusMedium
    DamascusSemiBold
 Devanagari Sangam MN
    DevanagariSangamMN
    DevanagariSangamMN-Bold
 Didot
    Didot
    Didot-Bold
    Didot-Italic
 Euphemia UCAS
    EuphemiaUCAS
    EuphemiaUCAS-Bold
    EuphemiaUCAS-Italic
 Farah
    Farah
 Futura
    Futura-Bold
    Futura-CondensedExtraBold
    Futura-CondensedMedium
    Futura-Medium
    Futura-MediumItalic
 Galvji
    Galvji
    Galvji-Bold
 Geeza Pro
    GeezaPro
    GeezaPro-Bold
 Georgia
    Georgia
    Georgia-Bold
    Georgia-BoldItalic
    Georgia-Italic
 Gill Sans
    GillSans
    GillSans-Bold
    GillSans-BoldItalic
    GillSans-Italic
    GillSans-Light
    GillSans-LightItalic
    GillSans-SemiBold
    GillSans-SemiBoldItalic
    GillSans-UltraBold
 Grantha Sangam MN
    GranthaSangamMN-Bold
    GranthaSangamMN-Regular
 Helvetica
    Helvetica
    Helvetica-Bold
    Helvetica-BoldOblique
    Helvetica-Light
    Helvetica-LightOblique
    Helvetica-Oblique
 Helvetica Neue
    HelveticaNeue
    HelveticaNeue-Bold
    HelveticaNeue-BoldItalic
    HelveticaNeue-CondensedBlack
    HelveticaNeue-CondensedBold
    HelveticaNeue-Italic
    HelveticaNeue-Light
    HelveticaNeue-LightItalic
    HelveticaNeue-Medium
    HelveticaNeue-MediumItalic
    HelveticaNeue-Thin
    HelveticaNeue-ThinItalic
    HelveticaNeue-UltraLight
    HelveticaNeue-UltraLightItalic
 Hiragino Maru Gothic ProN
    HiraMaruProN-W4
 Hiragino Mincho ProN
    HiraMinProN-W3
    HiraMinProN-W6
 Hiragino Sans
    HiraginoSans-W3
    HiraginoSans-W5
    HiraginoSans-W6
    HiraginoSans-W7
    HiraginoSans-W8
 Hoefler Text
    HoeflerText-Black
    HoeflerText-BlackItalic
    HoeflerText-Italic
    HoeflerText-Regular
 Impact
    Impact
 Kailasa
    Kailasa
    Kailasa-Bold
 Kefa
    Kefa-Regular
 Khmer Sangam MN
    KhmerSangamMN
 Kohinoor Bangla
    KohinoorBangla-Light
    KohinoorBangla-Regular
    KohinoorBangla-Semibold
 Kohinoor Devanagari
    KohinoorDevanagari-Light
    KohinoorDevanagari-Regular
    KohinoorDevanagari-Semibold
 Kohinoor Gujarati
    KohinoorGujarati-Bold
    KohinoorGujarati-Light
    KohinoorGujarati-Regular
 Kohinoor Telugu
    KohinoorTelugu-Light
    KohinoorTelugu-Medium
    KohinoorTelugu-Regular
 Lao Sangam MN
    LaoSangamMN
 Malayalam Sangam MN
    MalayalamSangamMN
    MalayalamSangamMN-Bold
 Marker Felt
    MarkerFelt-Thin
    MarkerFelt-Wide
 Menlo
    Menlo-Bold
    Menlo-BoldItalic
    Menlo-Italic
    Menlo-Regular
 Mishafi
    DiwanMishafi
 Mukta Mahee
    MuktaMahee-Bold
    MuktaMahee-Light
    MuktaMahee-Regular
 Myanmar Sangam MN
    MyanmarSangamMN
    MyanmarSangamMN-Bold
 Noteworthy
    Noteworthy-Bold
    Noteworthy-Light
 Noto Nastaliq Urdu
    NotoNastaliqUrdu
    NotoNastaliqUrdu-Bold
 Noto Sans Kannada
    NotoSansKannada-Bold
    NotoSansKannada-Light
    NotoSansKannada-Regular
 Noto Sans Myanmar
    NotoSansMyanmar-Bold
    NotoSansMyanmar-Light
    NotoSansMyanmar-Regular
 Noto Sans Oriya
    NotoSansOriya
    NotoSansOriya-Bold
 Optima
    Optima-Bold
    Optima-BoldItalic
    Optima-ExtraBlack
    Optima-Italic
    Optima-Regular
 Palatino
    Palatino-Bold
    Palatino-BoldItalic
    Palatino-Italic
    Palatino-Roman
 Papyrus
    Papyrus
    Papyrus-Condensed
 Party LET
    PartyLetPlain
 PingFang HK
    PingFangHK-Light
    PingFangHK-Medium
    PingFangHK-Regular
    PingFangHK-Semibold
    PingFangHK-Thin
    PingFangHK-Ultralight
 PingFang SC
    PingFangSC-Light
    PingFangSC-Medium
    PingFangSC-Regular
    PingFangSC-Semibold
    PingFangSC-Thin
    PingFangSC-Ultralight
 PingFang TC
    PingFangTC-Light
    PingFangTC-Medium
    PingFangTC-Regular
    PingFangTC-Semibold
    PingFangTC-Thin
    PingFangTC-Ultralight
 Rockwell
    Rockwell-Bold
    Rockwell-BoldItalic
    Rockwell-Italic
    Rockwell-Regular
 STIX Two Math
    STIXTwoMath-Regular
 STIX Two Text
    STIXTwoText
    STIXTwoText-Italic
    STIXTwoText-Italic_Bold-Italic
    STIXTwoText-Italic_Medium-Italic
    STIXTwoText-Italic_SemiBold-Italic
    STIXTwoText_Bold
    STIXTwoText_Medium
    STIXTwoText_SemiBold
 Savoye LET
    SavoyeLetPlain
 Sinhala Sangam MN
    SinhalaSangamMN
    SinhalaSangamMN-Bold
 Snell Roundhand
    SnellRoundhand
    SnellRoundhand-Black
    SnellRoundhand-Bold
 Symbol
    Symbol
 Tamil Sangam MN
    TamilSangamMN
    TamilSangamMN-Bold
 Thonburi
    Thonburi
    Thonburi-Bold
    Thonburi-Light
 Times New Roman
    TimesNewRomanPS-BoldItalicMT
    TimesNewRomanPS-BoldMT
    TimesNewRomanPS-ItalicMT
    TimesNewRomanPSMT
 Trebuchet MS
    Trebuchet-BoldItalic
    TrebuchetMS
    TrebuchetMS-Bold
    TrebuchetMS-Italic
 Verdana
    Verdana
    Verdana-Bold
    Verdana-BoldItalic
    Verdana-Italic
 Zapf Dingbats
    ZapfDingbatsITC
 Zapfino
    Zapfino
 
 */

extension Font {
    
    static func viewHeadingFont(ofSize size: CGFloat) -> Font {
        return Font.custom("AppleSDGothicNeo-Medium", size: size)
    }
    
    static func titleFont(ofSize size: CGFloat) -> Font {
        return Font.custom("AppleSDGothicNeo-Medium", size: size)
    }
    
    static func sectionFont(ofSize size: CGFloat) -> Font {
        return Font.custom("AppleSDGothicNeo-SemiBold", size: size)
    }
    
    static func buttonFont(ofSize size: CGFloat) -> Font {
        return Font.custom("HelveticaNeue", size: size)
    }

    static func heading1Font(ofSize size: CGFloat) -> Font {
        return Font.custom("YourFontName-Heading1", size: size)
    }
    
    static func bodyFont(ofSize size: CGFloat) -> Font {
        return Font.custom("HelveticaNeue", size: size)
    }
    
    static func cardTitleFont(ofSize size: CGFloat) -> Font {
        return Font.custom("HelveticaNeue-Medium", size: size)
    }
    static func cardSubTitleFont(ofSize size: CGFloat) -> Font {
        return Font.custom("HelveticaNeue-Light", size: size)
    }

}
