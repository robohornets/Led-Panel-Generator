//
//  ShiftingLogic.swift
//  Led Panel Generator
//
//  Created by Caedmon Myers on 28/2/24.
//

import SwiftUI

struct ShiftingLogic: View {
    @State var passedArray: Array<Array<Int>>
    
    @State var length: Int
    @State var height: Int
    
    @State var iteration = 0
    
    var body: some View {
        VStack {
            Text(passedArray.description)
                .padding(20)
            
            HStack {
                Button {
                    scrollLeds()
                } label: {
                    Text("Scroll")
                }.buttonStyle(.borderedProminent)

            }
        }
    }
    
    func scrollLeds() {
        for i in 0..<height {
            passedArray.remove(at: i * length)
            
            if i != 0 {
                passedArray.insert([0, 0, 0], at: length * i - 1)
            }
        }
        passedArray.append([0, 0, 0])
    }
}


/*
 [1, 2, 3, 4]
 [5, 6, 7, 8]
 [9, 10, 11, 12]
 
 [x, 2, 3, 4]
 [x, 6, 7, 8]
 [9, 10, 11, 12]
 */
