//
//  Helper.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/18/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class DateFormat {
    
    var formatterDate: DateFormatter
    
    init(format: String) {
        
        formatterDate = DateFormatter()
        formatterDate.timeZone = TimeZone.current
        formatterDate.locale = Locale.current
        formatterDate.dateFormat = format
    }
    
    func getDateStr(dateMilli: Int) -> String {
        let date = NSDate(timeIntervalSince1970: Double(dateMilli))
        
        return formatterDate.string(from: date as Date)
    }
    
}
