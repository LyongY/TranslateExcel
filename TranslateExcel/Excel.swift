//
//  Excel.swift
//  TranslateExcel
//
//  Created by Raysharp666 on 2020/10/31.
//  Copyright © 2020 LyongY. All rights reserved.
//

import Foundation

struct ExcelItem {
    var col: Int
    var row: Int
    var value: String
    var language: Language
}

class Excel {
    private var path: String
    private var book: XLWorkbook
    private var sheet: XLWorksheet
    
    init?(path: String) {
        self.path = path
        guard let book = XLWorkbook(path: path) else {
            return nil
        }
        self.book = book
        sheet = book.sheet(with: 0)
    }
    
    private func findEmpty() -> [ExcelItem] {
        var emptyArr: [ExcelItem] = []
        let cols = sheet.colNum()
        let rows = sheet.rowNum()
        for col in 1...cols {
            for row in 1...rows {
                let languageStr = sheet.cell(withCol: col, row: 1).stringValue
                let language = Language(rawValue: languageStr)
                if language == nil {
                    continue
                }
                let value = sheet.cell(withCol: col, row: row).stringValue
                
                if value.count == 0 {
                    emptyArr.append(ExcelItem(col: Int(col), row: Int(row), value: value, language: language!))
                }
            }
        }
        return emptyArr
    }
    
    func completionEmptyItem(with language: Language, process: @escaping (_ finished: Bool, _ success: Bool, _ col: Int, _ row: Int, _ current: Int, _ total: Int) -> Void) {
        var fromLanguageCol_option: Int?
        let fromLanguageStr = language.rawValue
        let cols = sheet.colNum()
        for col in 1...cols {
            if fromLanguageStr == sheet.cell(withCol: col, row: 1).stringValue {
                fromLanguageCol_option = Int(col)
                break
            }
        }
        guard let fromLanguageCol = fromLanguageCol_option else {
            process(true, false, -1, -1, 0, 0)
            return
        }
        
        let emptyArr = findEmpty()
        
        let temp = copyExcel()
        let tempBook = temp.book
        let tempSheet = temp.sheet
        
        var translateCount = 0;
        var currentIndex = 0 // 当前是第几个翻译
        let totalCount = emptyArr.count
        for item in emptyArr {
            let fromWord = sheet.cell(withCol: UInt32(fromLanguageCol), row: UInt32(item.row)).stringValue
            if fromWord.count == 0 {
                currentIndex += 1
                if currentIndex == totalCount {
                    // 最后一个没有翻译完成, 写文件, 回调完成
                    let url = URL(fileURLWithPath: self.path)
                    let pathExtension = url.pathExtension
                    var path = self.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
                    path = path + Date().description + "." + pathExtension
                    tempBook.save(path)
                    process(true, false, -1, -1, currentIndex, totalCount)
                }
                continue
            }
            translateCount += 1
            TranslateAPI.word(fromWord, from: language, to: item.language) { (success, translateStr) in
                currentIndex += 1
                translateCount -= 1
                if success {
                    // 加入字段 Excel
                    tempSheet.cell(withCol: UInt32(item.col), row: UInt32(item.row)).stringValue = translateStr
                    process(false, true, item.col, item.row, currentIndex, totalCount)
                } else {
                    process(false, false, item.col, item.row, currentIndex, totalCount)
                }
                if translateCount == 0 {
                    // 翻译完成, 写文件
                    let url = URL(fileURLWithPath: self.path)
                    let pathExtension = url.pathExtension
                    var path = self.path.replacingOccurrences(of: ".\(pathExtension)", with: "")
                    path = path + Date().description + "." + pathExtension
                    tempBook.save(path)
                    process(true, true, 0, 0, currentIndex, totalCount)
                }
            }
        }
    }
    
    private func copyExcel() -> (book: XLWorkbook, sheet: XLWorksheet) {
        let book = XLWorkbook()
        let sheet = book.sheet(with: 0)
        let cols = self.sheet.colNum()
        let rows = self.sheet.rowNum()
        for col in 1...cols {
            for row in 1...rows {
                sheet.cell(withCol: col, row: row).stringValue = self.sheet.cell(withCol: col, row: row).stringValue
            }
        }
        return (book, sheet)
    }
}
