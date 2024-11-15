//
//  DateFormatManager.swift
//  KoCo
//
//  Created by 하연주 on 11/15/24.
//

import Foundation

final class DateFormatManager {
    static let shared = DateFormatManager()
    private init() {}
    
    enum FormatString : String {
//        case yearDotMonth = "yyyy.MM"
        case yearMonthDay = "yyyy-MM-dd"
    }
    
    
    private let krDateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "ko_KR")
        return formatter
    }()
    
    func getDateFormatter(format : FormatString) -> DateFormatter {
        let formatter = krDateFormatter
        formatter.dateFormat = format.rawValue
        return formatter
    }
}
