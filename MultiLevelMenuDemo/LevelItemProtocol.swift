//
//  LevelItemProtocol.swift
//  MultiLevelMenuDemo
//
//  Created by Passaction on 2017/8/15.
//  Copyright © 2017年 passaction. All rights reserved.
//

import Foundation

@objc protocol LeveItemProtocol: NSObjectProtocol {
    var levelName: String { get }
    var nextLevelItems: [LeveItemProtocol]? { get }
}
