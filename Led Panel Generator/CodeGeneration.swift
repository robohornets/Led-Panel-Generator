//
//  CodeGeneration.swift
//  Led Panel Generator
//
//  Created by Caedmon Myers on 27/2/24.
//

import SwiftUI


func generateArray(colors: Array<LedItem>, width: Int, height: Int) -> Array<Array<Int>> {
    var colorsAsArray = [] as [[Int]]
    
    var temporaryArray = [] as [[Int]]
    
    for x in 0..<32 {
        temporaryArray = []
        for y in 0..<8 {
            if colors[height * x + y].isOn {
                temporaryArray.append(hexStringToRGB(colors[height * x + y].color))
            } else {
                temporaryArray.append(hexStringToRGB("000000"))
            }
        }
        
        if x % 2 == 0 {
            for item in temporaryArray {
                colorsAsArray.append(item)
            }
        } else {
            for item in temporaryArray.reversed() {
                colorsAsArray.append(item)
            }
        }
    }
    
    
    print(colorsAsArray)
    
    return colorsAsArray
}


