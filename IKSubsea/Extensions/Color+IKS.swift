import SwiftUI

extension Color {
    // Core palette - official IK Subsea brand colours from ASE file
    static let iksNavy      = Color(IKSNavy)       // IK_grey_dark   #08171F - deep background
    static let iksNavyMid   = Color(IKSNavyMid)    // IK dark sea    #1B7A85 - card backgrounds
    static let iksTeal      = Color(IKSTeal)        // IK medium sea  #3BD9CC - primary accent / CTAs
    static let iksOrange    = Color(IKSOrange)      // Warm amber      #E07B30 - emergency / alerts
    static let iksWhite     = Color(IKSWhite)       // IK light sea   #A3FFDB - primary text on dark
    static let iksGrey      = Color(IKSGrey)        // IK_grey_light  #507E8A - secondary text

    // Extended palette
    static let iksSeaGreen  = Color(IKSSeaGreen)   // IK green sea   #66F2C2 - domain badges, accents
    static let iksMidGrey   = Color(IKSMidGrey)    // IK_grey_medium #214253 - muted / alternating rows
}
