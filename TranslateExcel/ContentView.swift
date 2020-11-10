//
//  ContentView.swift
//  TranslateExcel
//
//  Created by Raysharp666 on 2020/10/28.
//  Copyright © 2020 LyongY. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userData = UserData.default
    @State var baseLanguage: Language = .zh_Hans
    @State var processing: Bool = false
    var baseLanguages: [Language] = [.en, .zh_Hans, .zh_Hant]
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading) {

                    Picker("基准语言", selection: $baseLanguage) {
                        ForEach(baseLanguages) { (language) in
                            Text(language.rawValue).tag(language)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    Rectangle().frame(height: 0)

                    Text("Excel路径")
                    Text(UserData.default.excelPath ?? "拖入Excel")
                    
                    Rectangle().frame(height: 0)
                    
                    Text("未翻译项")
                    Text(UserData.default.translateErrorLog ?? "无错误")
                        .foregroundColor(UserData.default.translateErrorLog == nil ? .green : .red)
                }
                Spacer()
                
                VStack {
                    ProgressBar(maxValue: .constant(self.userData.totalCount), minValue: .constant(0), currentValue: .constant(self.userData.currentCount))
                    Button(action: {
                        UserData.default.translateErrorLog = nil;
                        if UserData.default.excelPath != nil && UserData.default.excelPath?.count != 0 {
                            let excel = Excel(path: UserData.default.excelPath!)
                            self.processing = true
                            excel?.completionEmptyItem(with: self.baseLanguage, process: { (finish, success, col, row, current, totalCount) in
                                self.processing = !finish
                                UserData.default.currentCount = current
                                UserData.default.totalCount = totalCount
                                if !success {
                                    if UserData.default.translateErrorLog == nil {
                                        UserData.default.translateErrorLog = ""
                                    }
                                    if let scalar = UnicodeScalar(col + 64) {
                                        if col >= 1 && col <= 26 {
                                            let char = Character(scalar)
                                            UserData.default.translateErrorLog! += "\(char)\(row)  "
                                        } else {
                                            UserData.default.translateErrorLog! += "(col:\(col), row:\(row))  "
                                        }
                                    } else {
                                        UserData.default.translateErrorLog! += "(col:\(col), row:\(row))  "
                                    }
                                }
                            })
                        }
                    }) {
                        Text("开始翻译")
                            .frame(width: 300)
                            .contentShape(Rectangle())
                    }.disabled(processing)
                }
            }.padding()
            DragView(enable: { (path) -> Bool in
                path.hasSuffix(".xlsx")
            }) { (path) in
                UserData.default.excelPath = path
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
