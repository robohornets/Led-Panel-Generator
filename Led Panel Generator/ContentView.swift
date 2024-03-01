//
//  ContentView.swift
//  Led Panel Generator
//
//  Created by Caedmon Myers on 24/2/24.
//

import SwiftUI

let FALSE = false

struct ContentView: View {
    @State var length = "32"
    @State var height = "8"
    
    @State var generatedGrid = false
    
    @State var columns: [GridItem] = []
    
    @State var leds: [LedItem] = []
    
    @State var color = "0000FF"
    
    @State private var showingColorPicker = false
    @State private var selectedColor = Color.blue
    @State private var selectedIndex: Int? = nil
    
    @State var loadFrom = "led"
    
    @State var savedFirstSelectionIndex = ""
    
    @State var tempColor = ""
    
    @State var mainColor = "0000FF"
    @State var mainColorBinding = Color(hex: "0000FF")
    
    @State private var isSelectionMode = false
    @State private var firstSelectedIndex: Int? = nil
    @State private var secondSelectedIndex: Int? = nil
    
    @State var savedArray = (UserDefaults.standard.stringArray(forKey: "savednames") ?? []) as [String]
    
    @State var savedDictHeight = (UserDefaults.standard.dictionary(forKey: "savedHeights") ?? [:]) as? [String: Int]
    
    @State var savedDictWidth = (UserDefaults.standard.dictionary(forKey: "savedWidths") ?? [:]) as? [String: Int]
    
    @State private var currentScale: CGFloat = 1.0
    @State private var cumulativeScale: CGFloat = 1.0
    
    @State var blurCircles = false
    
    @State var collapseMenu = false
    @State var collapseMenuAnimation = false
    
    @State var backgroundColor = "FFFFFF"
    @State var backgroundColorBinding = Color(hex: "FFFFFF")
    
    @State var generatedCode = [] as [[Int]]
    @State var formattedGeneratedCode = ""
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if !generatedGrid {
                    ZStack {
                        VStack(spacing: 30) {
                            TextField("Length", text: $length)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .hoverEffect(.lift)
                            
                            TextField("Height", text: $height)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .hoverEffect(.lift)
                            
                            TextField("Color", text: $mainColor)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled(true)
                                .hoverEffect(.lift)
                            
                            TextField("Load From", text: $loadFrom)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .hoverEffect(.lift)
                            
                            Button {
                                if savedArray.contains(loadFrom) {
                                    savedArray.remove(at: savedArray.firstIndex(of: loadFrom)!)
                                }
                            } label: {
                                Text("Remove")
                            }.buttonStyle(.borderedProminent)
                                .hoverEffect(.lift)

                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(savedArray, id:\.self) { item in
                                        Button(action: {
                                            loadFrom = item
                                            
                                            if savedDictWidth?[item] != nil {
                                                length = String(savedDictWidth?[item] ?? 32)
                                            }
                                            
                                            if savedDictHeight?[item] != nil {
                                                height = String(savedDictHeight?[item] ?? 8)
                                            }
                                        }, label: {
                                            Text(item)
                                        }).buttonStyle(.bordered)
                                            .padding(10)
                                            .hoverEffect(.lift)
                                    }
                                }
                            }
                            
                            Button(action: {
                                leds.removeAll()
                                
                                columns = Array(repeating: .init(.flexible()), count: Int(height) ?? 4)
                                
                                // Before accessing UserDefaults, check if the key exists
                                let ledBoolsKey = "\(loadFrom)Bools"
                                let ledColorsKey = "\(loadFrom)Colors"
                                let defaultLedsCount = (Int(length) ?? 4) * (Int(height) ?? 4)
                                
                                savedDictWidth?[loadFrom] = Int(length)
                                savedDictHeight?[loadFrom] = Int(height)
                                
                                UserDefaults.standard.setValue(savedDictHeight, forKey: "savedHeights")
                                UserDefaults.standard.setValue(savedDictWidth, forKey: "savedWidths")
                                
                                if let savedBools = UserDefaults.standard.array(forKey: ledBoolsKey) as? [Bool],
                                   let savedColors = UserDefaults.standard.stringArray(forKey: ledColorsKey),
                                   savedBools.count >= defaultLedsCount {
                                    for i in 0..<defaultLedsCount {
                                        leds.append(LedItem(isOn: savedBools[i], color: savedColors[i]))
                                    }
                                } else {
                                    leds = Array(repeating: LedItem(isOn: false, color: mainColor), count: defaultLedsCount)
                                }
                                
                                // Save the array to UserDefaults
                                if !savedArray.contains(loadFrom) {
                                    savedArray.append(loadFrom)
                                    UserDefaults.standard.setValue(savedArray, forKey: "savednames")
                                }
                                
                                generatedGrid = true
                            }, label: {
                                Text("Continue")
                            }).buttonStyle(.borderedProminent)
                                .hoverEffect(.lift)
                            
                            
                        }.padding(20)
                    }
                } else {
                    ZStack {
                        HStack {
                            Button {
                                if !formattedGeneratedCode.isEmpty {
                                    UIPasteboard.general.string = formattedGeneratedCode
                                }
                            } label: {
                                Text("Copy")
                            }.keyboardShortcut("c")
                            
                            
                            Button {
                                generatedCode = generateArray(colors: leds, width: Int(length) ?? 32, height: Int(height) ?? 8)
                                
                                formattedGeneratedCode += "{"
                                for colorObject in generatedCode {
                                    formattedGeneratedCode += "{"
                                    for colorValue in 0..<colorObject.count {
                                        formattedGeneratedCode += String(colorObject[colorValue])
                                        if colorValue != 2 {
                                            formattedGeneratedCode += ", "
                                        }
                                    }
                                    formattedGeneratedCode += "},"
                                }
                                formattedGeneratedCode += "};"
                                
                            } label: {
                                Text("Generate Array")
                            }.buttonStyle(.bordered)
                                .hoverEffect(.lift)
                                .keyboardShortcut("r")
                            
                            Button {
                                cumulativeScale -= 0.1
                            } label: {
                                Text("Zoom Out")
                                    .frame(width: 0)
                                    .clipped()
                            }.hidden()
                                .keyboardShortcut("-")
                            
                            
                            Button("Shift Left") { shiftLeft() }.buttonStyle(.bordered)
                                .hoverEffect(.lift)
                                .keyboardShortcut(.leftArrow, modifiers: .command)
                            
                            Button("Shift Right") { shiftRight() }.buttonStyle(.bordered)
                                .hoverEffect(.lift)
                                .keyboardShortcut(.rightArrow, modifiers: .command)
                            
                            Button(isSelectionMode ? "Single Selection": "Row Selection") {
                                isSelectionMode.toggle()
                                firstSelectedIndex = nil
                                secondSelectedIndex = nil
                            }.buttonStyle(.borderedProminent)
                                .hoverEffect(.lift)
                            
                            Button("Shift Up") { shiftUp() }.buttonStyle(.bordered)
                                .hoverEffect(.lift)
                                .keyboardShortcut(.upArrow, modifiers: .command)
                            
                            Button("Shift Down") { shiftDown() }.buttonStyle(.bordered)
                                .hoverEffect(.lift)
                                .keyboardShortcut(.downArrow, modifiers: .command)
                            
                            Button(blurCircles ? "Un-blur": "Blur") { blurCircles.toggle() }.buttonStyle(.borderedProminent)
                                .hoverEffect(.lift)
                                .keyboardShortcut("b", modifiers: [.command, .shift])
                            
                            
                            Button {
                                cumulativeScale += 0.1
                            } label: {
                                Text("Zoom In")
                                    .frame(width: 0)
                                    .clipped()
                            }.hidden()
                                .keyboardShortcut("=")
                            
                        }.hidden()
                        
                        
                        Color(backgroundColorBinding)
                            .ignoresSafeArea()
                        
                        VStack {
                            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                                ZStack {
                                    Color(backgroundColor)
                                    
                                    LazyHGrid(rows: columns, content: {
                                        ForEach(leds.indices, id: \.self) { index in
                                            Circle()
                                                .fill(Color(hex: leds[index].isOn ? leds[index].color : "A9A9A9"))
                                            //.frame(width: (geo.size.width / CGFloat(Int(length) ?? 4) - 10) * currentScale)
                                                .frame(width:  90 * cumulativeScale)
                                                .blur(radius: blurCircles ? 10: 0)
                                                .padding(10 * cumulativeScale)
                                                .onTapGesture {
                                                    if isSelectionMode {
                                                        if firstSelectedIndex == nil {
                                                            firstSelectedIndex = index
                                                            leds[index].isOn.toggle()
                                                            if leds[index].isOn {
                                                                leds[index].color = mainColor
                                                            }
                                                            
                                                        } else if secondSelectedIndex == nil {
                                                            secondSelectedIndex = index
                                                            
                                                            leds[firstSelectedIndex ?? 0].isOn.toggle()
                                                            
                                                            toggleInRange(firstIndex: firstSelectedIndex!, secondIndex: secondSelectedIndex!)
                                                        }
                                                    } else {
                                                        leds[index].isOn.toggle()
                                                        if leds[index].isOn {
                                                            leds[index].color = mainColor
                                                        }
                                                    }
                                                }
                                                .onChange(of: leds, perform: { value in
                                                    var ledBools = [] as [Bool]
                                                    var ledColors = [] as [String]
                                                    for led in leds {
                                                        ledBools.append(led.isOn)
                                                        ledColors.append(led.color)
                                                    }
                                                    UserDefaults.standard.setValue(ledBools, forKey: "\(loadFrom)Bools")
                                                    UserDefaults.standard.setValue(ledColors, forKey: "\(loadFrom)Colors")
                                                })
                                        }
                                    })
                                }
                                //.scaleEffect(currentScale) // Apply scale effect here
                                .simultaneousGesture(MagnificationGesture().onChanged { value in
                                    let delta = value / self.currentScale
                                    self.currentScale = value // Update the last scale value with the current gesture value
                                    self.cumulativeScale *= delta // Adjust the cumulative scale
                                }.onEnded { value in
                                    // When the gesture ends, reset lastScaleValue for the next gesture,
                                    // but keep the cumulativeScale as is to maintain the zoom level
                                    self.currentScale = 1.0
                                })
                            }
                            
                        }
                        
                        VStack(spacing: 0) {
                            HStack {
                                Button {
                                    generatedGrid = false
                                } label: {
                                    Label("Back", systemImage: "chevron.left")
                                        .bold()
                                        .padding(20)
                                }
                                .hoverEffect(.highlight)
                                
                                Spacer()
                                    .frame(width: 50)
                                
                                Button {
                                    if !collapseMenu {
                                        withAnimation(.bouncy) {
                                            collapseMenu.toggle()
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.bouncy) {
                                                collapseMenuAnimation.toggle()
                                            }
                                        }
                                    } else {
                                        withAnimation(.bouncy) {
                                            collapseMenuAnimation.toggle()
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.bouncy) {
                                                collapseMenu.toggle()
                                            }
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Material.ultraThick)
                                            .frame(width: 30)
                                        
                                        Image(systemName: "chevron.left")
                                            .rotationEffect(Angle(degrees: collapseMenu ? -180: 0))
                                            .foregroundStyle(Color.black)
                                    }
                                }.keyboardShortcut("l")
                                
                                
                                Spacer()
                                
                            }.background(Rectangle().fill(Material.thick))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    VStack(spacing: 0) {
                                        HStack {
                                            VStack {
                                                
                                                HStack {
                                                    Text("#")
                                                        .padding(0)
                                                        .bold()
                                                        .opacity(0.5)
                                                    
                                                    TextField("Hex Color", text: $mainColor)
                                                        .textFieldStyle(.roundedBorder)
                                                        .textInputAutocapitalization(.characters)
                                                        .autocorrectionDisabled(true)
                                                        .hoverEffect(.lift)
                                                    
                                                    Button(action: {
                                                        if mainColor.count == 6 {
                                                            mainColorBinding = Color(hex: mainColor)
                                                        }
                                                    }, label: {
                                                        Text("Update Color")
                                                    }).buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
                                                    ColorPicker("", selection: $mainColorBinding, supportsOpacity: false)
                                                        .onChange(of: mainColorBinding) { newColor in
                                                            mainColor = newColor.toHexString()
                                                        }
                                                        .hoverEffect(.lift)
                                                    
                                                }.frame(width: collapseMenu ? 0: .infinity)
                                                    .clipped()
                                                    .padding(50)
                                                    .onAppear() {
                                                        mainColorBinding = Color(hex: mainColor)
                                                    }
                                                    .frame()
                                                
                                                HStack {
                                                    Button {
                                                        cumulativeScale -= 0.1
                                                    } label: {
                                                        Text("Zoom Out")
                                                            .frame(width: 0)
                                                            .clipped()
                                                    }.hidden()
                                                    
                                                    
                                                    
                                                    Button("Shift Left") { shiftLeft() }.buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
                                                    
                                                    Button("Shift Right") { shiftRight() }.buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
                                                    
                                                    Button(isSelectionMode ? "Single Selection": "Row Selection") {
                                                        isSelectionMode.toggle()
                                                        firstSelectedIndex = nil
                                                        secondSelectedIndex = nil
                                                    }.buttonStyle(.borderedProminent)
                                                        .hoverEffect(.lift)
                                                    
                                                    Button("Shift Up") { shiftUp() }.buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
                                                    
                                                    Button("Shift Down") { shiftDown() }.buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
                                                    
                                                    Button(blurCircles ? "Un-blur": "Blur") { blurCircles.toggle() }.buttonStyle(.borderedProminent)
                                                        .hoverEffect(.lift)
                                                    
                                                    
                                                    
                                                    Button {
                                                        cumulativeScale += 0.1
                                                    } label: {
                                                        Text("Zoom In")
                                                            .frame(width: 0)
                                                            .clipped()
                                                    }.hidden()
                                                    
                                                    
                                                }.frame(width: collapseMenu ? 0: nil)
                                                    .clipped()
                                            }.background(Rectangle().fill(Material.regular))
                                                .cornerRadius(50)
                                        }
                                    }.frame(width: geo.size.width - 100, height: collapseMenuAnimation ? 0: nil)
                                        .padding(20)
                                        .offset(y: collapseMenuAnimation ? 100: 0)
                                        .clipped()
                                    
                                    VStack(spacing: 0) {
                                        HStack {
                                            VStack {
                                                
                                                HStack {
                                                    Text("#")
                                                        .padding(0)
                                                        .bold()
                                                        .opacity(0.5)
                                                    
                                                    TextField("Background Color", text: $backgroundColor)
                                                        .textFieldStyle(.roundedBorder)
                                                        .textInputAutocapitalization(.characters)
                                                        .autocorrectionDisabled(true)
                                                        .hoverEffect(.lift)
                                                    
                                                    Button(action: {
                                                        if backgroundColor.count == 6 {
                                                            backgroundColorBinding = Color(hex: backgroundColor)
                                                        }
                                                    }, label: {
                                                        Text("Update Background")
                                                    }).buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
                                                    ColorPicker("", selection: $backgroundColorBinding, supportsOpacity: false)
                                                        .onChange(of: backgroundColorBinding) { newColor in
                                                            backgroundColor = newColor.toHexString()
                                                        }
                                                        .hoverEffect(.lift)
                                                    
                                                }.frame(width: collapseMenu ? 0: .infinity)
                                                    .clipped()
                                                    .padding(50)
                                                    .onAppear() {
                                                        backgroundColorBinding = Color(hex: backgroundColor)
                                                    }
                                                    .frame()
                                                
                                                
//                                                HStack {
//                                                    ScrollView(.horizontal, showsIndicators: false) {
//                                                        HStack {
//                                                            ForEach(savedArray, id:\.self) { item in
//                                                                Button(action: {
//                                                                    loadFrom = item
//                                                                    
//                                                                    if savedDictWidth?[item] != nil {
//                                                                        length = String(savedDictWidth?[item] ?? 32)
//                                                                    }
//                                                                    
//                                                                    if savedDictHeight?[item] != nil {
//                                                                        height = String(savedDictHeight?[item] ?? 8)
//                                                                    }
//                                                                }, label: {
//                                                                    Text(item)
//                                                                }).buttonStyle(.bordered)
//                                                                    .padding(10)
//                                                                    .hoverEffect(.lift)
//                                                            }
//                                                        }
//                                                    }
//                                                }.frame(width: collapseMenu ? 0: .infinity)
//                                                    .clipped()
                                                
                                                
                                                HStack {
                                                    Button {
                                                        formattedGeneratedCode = ""
                                                        generatedCode = generateArray(colors: leds, width: Int(length) ?? 32, height: Int(height) ?? 8)
                                                        
                                                        formattedGeneratedCode += "{"
                                                        for colorObject in generatedCode {
                                                            formattedGeneratedCode += "{"
                                                            for colorValue in 0..<colorObject.count {
                                                                formattedGeneratedCode += String(colorObject[colorValue])
                                                                if colorValue != 2 {
                                                                    formattedGeneratedCode += ", "
                                                                }
                                                            }
                                                            formattedGeneratedCode += "},"
                                                        }
                                                        formattedGeneratedCode += "};"
                                                        
                                                    } label: {
                                                        Text("Generate Array")
                                                    }.buttonStyle(.bordered)
                                                        .hoverEffect(.lift)
                                                    
//                                                    Button {
//                                                        //
//                                                    } label: {
//                                                        Text("Generate Initial Code")
//                                                    }.buttonStyle(.bordered)
//                                                        .hoverEffect(.lift)
//                                                    
//                                                    Button {
//                                                        //
//                                                    } label: {
//                                                        Text("Generate Update Code")
//                                                    }.buttonStyle(.bordered)
//                                                        .hoverEffect(.lift)
                                                    
                                                    
                                                }.frame(width: collapseMenu ? 0: .infinity)
                                                    .clipped()
                                            }.background(Rectangle().fill(Material.regular))
                                                .cornerRadius(50)
                                        }
                                    }.frame(width: geo.size.width - 150, height: collapseMenuAnimation ? 0: .infinity)
                                        .padding(20)
                                        .offset(y: collapseMenuAnimation ? 100: 0)
                                        .clipped()
                                    
                                    
                                    if !formattedGeneratedCode.isEmpty {
                                        VStack(spacing: 0) {
                                            HStack {
                                                VStack {
                                                    
                                                    HStack {
                                                        ScrollView {
                                                            Text(formattedGeneratedCode)
                                                                .padding(10)
                                                            
                                                            Text(generatedCode.description.replacingOccurrences(of: "[", with: "{").replacingOccurrences(of: "]", with: "}"))
                                                                .padding(10)
                                                            
                                                            HStack {
                                                                Button {
                                                                    UIPasteboard.general.string = formattedGeneratedCode
                                                                } label: {
                                                                    Text("Copy")
                                                                }.buttonStyle(.borderedProminent)
                                                                    .hoverEffect(.lift)
                                                                
                                                                Button {
                                                                    generatedCode.description.replacingOccurrences(of: "[", with: "{").replacingOccurrences(of: "]", with: "}")
                                                                } label: {
                                                                    Text("Copy")
                                                                }.buttonStyle(.bordered)
                                                                    .hoverEffect(.lift)
                                                                
                                                                
                                                            }.frame(width: collapseMenu ? 0: .infinity)
                                                                .clipped()
                                                            
                                                            
                                                            NavigationLink {
                                                                ShiftingLogic(passedArray: generatedCode, length: Int(length) ?? 0, height: Int(height) ?? 0)
                                                            } label: {
                                                                Text("Test Shifting")
                                                            }.buttonStyle(.borderedProminent)
                                                                .hoverEffect(.lift)
                                                            
                                                            
                                                            
                                                        }.frame(height: 200)
                                                        
                                                    }.frame(width: collapseMenu ? 0: .infinity)
                                                        .clipped()
                                                        .padding(.top, 50)
                                                        .onAppear() {
                                                            mainColorBinding = Color(hex: mainColor)
                                                        }
                                                        .frame()
                                                }.background(Rectangle().fill(Material.regular))
                                                    .cornerRadius(50)
                                            }
                                        }.frame(width: geo.size.width - 150, height: collapseMenuAnimation ? 0: 300)
                                            .padding(20)
                                            .offset(y: collapseMenuAnimation ? 100: 0)
                                            .clipped()
                                    }
                                    
                                }.scrollTargetLayout()
                            }.scrollTargetBehavior(.viewAligned)
                                .frame(height: collapseMenuAnimation ? 0: 300)
                            
                            Spacer()
                        }.ignoresSafeArea()
                    }
                }
            }
        }
    }
    
    private func toggleInRange(firstIndex: Int, secondIndex: Int) {
        let rowLength = Int(length) ?? 0
        let firstRow = firstIndex / rowLength
        let secondRow = secondIndex / rowLength
        let firstCol = firstIndex % rowLength
        let secondCol = secondIndex % rowLength
        
        if firstRow == secondRow {
            let range = (firstCol < secondCol) ? firstCol...secondCol : secondCol...firstCol
            for col in range {
                let index = firstRow * rowLength + col
                toggleLed(at: index)
            }
        } else if firstCol == secondCol {
            let range = (firstRow < secondRow) ? firstRow...secondRow : secondRow...firstRow
            for row in range {
                let index = row * rowLength + firstCol
                toggleLed(at: index)
            }
        }
        
        // Reset selections
        firstSelectedIndex = nil
        secondSelectedIndex = nil
    }
    
    private func toggleLed(at index: Int) {
        leds[index].isOn.toggle()
        if leds[index].isOn {
            leds[index].color = mainColor
        }
    }
    
    // Shift the LEDs one position to the left
    private func shiftLeft() {
        let rowLength = Int(length) ?? 0
        for i in 0..<leds.count {
            let newRow = (i / rowLength) * rowLength
            let newI = i % rowLength == 0 ? newRow + rowLength - 1 : i - 1
            leds.swapAt(i, newI)
        }
    }


        // Shift the LEDs one position to the right
    private func shiftRight() {
        let rowLength = Int(length) ?? 0
        for i in stride(from: leds.count - 1, through: 0, by: -1) {
            let newRow = (i / rowLength) * rowLength
            let newI = i % rowLength == (rowLength - 1) ? newRow : i + 1
            leds.swapAt(i, newI)
        }
    }


        // Shift the LEDs one position up
    private func shiftUp() {
        let rowLength = Int(length) ?? 0
        let columnCount = Int(height) ?? 0 // Assuming `height` represents the number of rows in the grid
        for col in 0..<rowLength {
            for row in 0..<columnCount {
                let i = row * rowLength + col
                let newI = row == 0 ? (columnCount - 1) * rowLength + col : i - rowLength
                leds.swapAt(i, newI)
            }
        }
    }


        // Shift the LEDs one position down
    private func shiftDown() {
        let rowLength = Int(length) ?? 0
        let columnCount = Int(height) ?? 0 // Assuming `height` represents the number of rows in the grid
        for col in 0..<rowLength {
            for row in stride(from: columnCount - 1, through: 0, by: -1) {
                let i = row * rowLength + col
                let newI = row == (columnCount - 1) ? col : i + rowLength
                leds.swapAt(i, newI)
            }
        }
    }
}

struct LedItem: Equatable {
    var id = UUID()
    var isOn: Bool
    var color: String
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
}


#Preview(body: {
    ContentView()
})
