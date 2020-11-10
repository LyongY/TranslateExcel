//
//  UserData.swift
//  TranslateExcel
//
//  Created by Raysharp666 on 2020/10/31.
//  Copyright © 2020 LyongY. All rights reserved.
//

import Foundation

class UserData: ObservableObject {
    @Published var excelPath: String?
    @Published var translateErrorLog: String?
    
    @Published var totalCount: Int = 0
    @Published var currentCount: Int = 0
    
    static let `default` = UserData()
    private init() {}
}
