//
//  CityViewModel.swift
//  MultiLevelMenuDemo
//
//  Created by Passaction on 2017/8/15.
//  Copyright © 2017年 passaction. All rights reserved.
//

import Foundation
import Unbox

class CityViewModel {
    
    lazy var cityArray: [CityModel]? = self.convertJSONDataToCityModel()
    
    private func convertJSONDataToCityModel() -> [CityModel]? {
        guard let filePath = Bundle.main.url(forResource: "china-city-info", withExtension: "json"),
            let data = try? Data(contentsOf: filePath) else {
                return nil
        }
        
        do {
            let cityArray: [CityModel] = try unbox(data: data)
            return cityArray
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
}
