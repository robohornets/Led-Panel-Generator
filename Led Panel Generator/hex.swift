//
//  hex.swift
//  Led Panel Generator
//
//  Created by Caedmon Myers on 24/2/24.
//

import SwiftUI


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    func toHexString() -> String {
        let components = UIColor(self).cgColor.components
        let r: CGFloat = components?[0] ?? 0
        let g: CGFloat = components?[1] ?? 0
        let b: CGFloat = components?[2] ?? 0
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    
}

func hexStringToRGB(_ hex: String) -> [Int] {
    // Ensure hex is in the correct format
    let trimmedString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    let hexString = trimmedString.hasPrefix("#") ? String(trimmedString.dropFirst()) : trimmedString

    // Default RGB values
    var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
    
    // Ensure the hex string is valid
    guard hexString.count == 6, Scanner(string: hexString).scanHexInt64(&r) else {
        print("Invalid hex string")
        return [0, 0, 0] // Return black or an error indicator
    }
    
    // Extract RGB values
    Scanner(string: String(hexString.prefix(2))).scanHexInt64(&r)
    Scanner(string: String(hexString[hexString.index(hexString.startIndex, offsetBy: 2)...hexString.index(hexString.startIndex, offsetBy: 3)])).scanHexInt64(&g)
    Scanner(string: String(hexString.suffix(2))).scanHexInt64(&b)

    return [Int(r), Int(g), Int(b)]
}

func rgbToHex(r: Int, g: Int, b: Int) -> String {
//    let components = UIColor(self).cgColor.components
//    let r: CGFloat = components?[0] ?? 0
//    let g: CGFloat = components?[1] ?? 0
//    let b: CGFloat = components?[2] ?? 0
    return String(format: "%02X%02X%02X", Int(r), Int(g), Int(b))
}
