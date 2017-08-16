//
//  CityModel.swift
//  MultiLevelMenuDemo
//
//  Created by Passaction on 2017/8/15.
//  Copyright © 2017年 passaction. All rights reserved.
//

import Foundation
import Unbox

class CityModel: NSObject, Unboxable, LeveItemProtocol {
    
    let name: String
    let subCitys: [CityModel]?
    
    var levelName: String {
        return self.name
    }
    
    var nextLevelItems: [LeveItemProtocol]? {
        return self.subCitys
    }
    
    required init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "name")
        subCitys = unboxer.unbox(key: "sub")
    }
}
