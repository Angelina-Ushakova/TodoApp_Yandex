import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String {
        let components = self.cgColor?.components
        let r = components?[0] ?? 0.0
        let g = components?[1] ?? 0.0
        let b = (components?.count ?? 0) > 2 ? components?[2] ?? 0.0 : g
        return String(format: "#%02X%02X%02X", Int(r * 255.0), Int(g * 255.0), Int(b * 255.0))
    }
}
