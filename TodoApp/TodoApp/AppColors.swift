import SwiftUI

enum AppColors {
    enum Label {
        static let primary = Color("labelPrimary")
        static let secondary = Color("labelSecondary")
        static let tertiary = Color("labelTertiary")
        static let disable = Color("labelDisable")
    }
    
    enum Back {
        static let elevated = Color("backElevated")
        static let primary = Color("backPrimary")
        static let iOSPrimary = Color("backiOSPrimary")
        static let secondary = Color("backSecondary")
    }
    
    enum Support {
        static let overlay = Color("supportOverlay")
        static let separator = Color("supportSeparator")
        static let navBarBlur = Color("supportNavBarBlur")
    }
    
    static let white = Color("colorWhite")
    static let red = Color("colorRed")
    static let green = Color("colorGreen")
    static let blue = Color("colorBlue")
    static let gray = Color("colorGray")
    static let lightGray = Color("colorLightGray")
    static let clear = Color.clear
}
