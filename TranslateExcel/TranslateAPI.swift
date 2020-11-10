//
//  TranslateAPI.swift
//  TranslateExcel
//
//  Created by Raysharp666 on 2020/10/30.
//  Copyright © 2020 LyongY. All rights reserved.
//

import Foundation
import CryptoKit

enum Language: String, CaseIterable, Identifiable {
    case en, fr, ru, de, it, nl, pl, tr, pt, es, ja, ko, uk, ar, vi
    case zh_Hans = "zh-Hans", zh_Hant = "zh-Hant"
    
    var id: String {
        rawValue
    }
    
    var baidu: String {
        var language = "en"
        switch self {
        case .zh_Hans:
            language = "zh"
        case .zh_Hant:
            language = "cht"
        case .fr:
            language = "fra"
        case .es:
            language = "spa"
        case .ja:
            language = "jp"
        case .ko:
            language = "kor"
        case .uk:
            language = "ukr"
        case .ar:
            language = "ara"
        case .vi:
            language = "vie"
        default:
            language = self.rawValue
        }
        return language
    }
}

class TranslateAPI {
    static let semaphore = DispatchSemaphore(value: 0)
    static let queue = DispatchQueue(label: "baidu", qos: .userInteractive)
    static func word(_ word: String, from: Language = .zh_Hans, to: Language, complete: @escaping (_ success: Bool, _ word: String)->Void) {
        
        #warning("请于百度开放平台申请appid及key")
        let appid = "请于百度开放平台申请"
        let key = "请于百度开放平台申请"
        let salt = self.createRandonSalt()
        var sign = appid + word + salt + key
        let digest = Insecure.MD5.hash(data: sign.data(using: .utf8)!)
        sign = digest.map{String(format: "%02hhx", $0)}.joined()
        let fff = [
            ("q", word),
            ("from", from.baidu),
            ("to", to.baidu),
            ("appid", appid),
            ("salt", salt),
            ("sign", sign)
        ]
        let bodyStr = fff.map{"\($0.0)=\($0.1)"}.joined(separator: "&")

        let requestStr = "https://fanyi-api.baidu.com/api/trans/vip/translate?" + bodyStr
        
        var request = URLRequest(url: URL(string: requestStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        request.httpMethod = "GET"
        
        let sesstion = URLSession(configuration: .default)
        queue.async {
            sesstion.dataTask(with: request) { (data, rsp, err) in
                guard let data = data,
                    let dic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
                    let trans_result = dic["trans_result"] as? [NSDictionary],
                    let result = trans_result.first?["dst"] as? String else {
                        DispatchQueue.main.async {
                            complete(false, "")
                        }
                        usleep(1000000)
                        semaphore.signal()
                        return
                }
                DispatchQueue.main.async {
                    complete(true, result)
                }
                usleep(1000000)
                semaphore.signal()
            }.resume()
            semaphore.wait()
        }
    }
    
    static func createRandonSalt() -> String {
        let all = "1234567890poiuytrewqasdfghjklmnbvcxzZXCVBNMLKJHGFDSAQWERTYUIOP"
        var salt = ""
        for _ in 0..<20 {
            let i = Int(arc4random() % UInt32(all.count))
            let start = all.index(all.startIndex, offsetBy: i)
            let end = all.index(all.startIndex, offsetBy: i + 1)
            let r = all[start..<end]
            salt += String(r)
        }
        return salt
    }
}
