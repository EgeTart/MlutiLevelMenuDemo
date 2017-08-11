//
//  HomeViewController.swift
//  MultiLevelMenuDemo
//
//  Created by Passaction on 2017/8/11.
//  Copyright © 2017年 passaction. All rights reserved.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    private lazy var cityButton: UIButton = {
        return self.createButton(title: "城市")
    }()
    
    private lazy var musicButton: UIButton = {
        return self.createButton(title: "音乐")
    }()
    
    private lazy var movieButton: UIButton = {
        return self.createButton(title: "电影")
    }()
    
    private lazy var verticalLine1: UIView = {
        return self.createSeparateLine()
    }()
    
    private lazy var verticalLine2: UIView = {
        return self.createSeparateLine()
    }()
    
    private lazy var horizontalLine: UIView = {
        return self.createSeparateLine()
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "首页"
        self.view.backgroundColor = UIColor(white: 0.99, alpha: 1.0)
        
        configureLayout()
    }
    
    private func configureLayout() {
        self.view.addSubview(cityButton)
        self.view.addSubview(musicButton)
        self.view.addSubview(movieButton)
        self.view.addSubview(verticalLine1)
        self.view.addSubview(verticalLine2)
        self.view.addSubview(horizontalLine)
        
        cityButton.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3)
            make.height.equalTo(44.0)
        }
        
        musicButton.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(self.cityButton)
            make.leading.equalTo(self.cityButton.snp.trailing)
        }
        
        movieButton.snp.makeConstraints { (make) in
            make.top.height.width.equalTo(self.musicButton)
            make.trailing.equalToSuperview()
        }
        
        verticalLine1.snp.makeConstraints { (make) in
            make.top.equalTo(self.cityButton).offset(4);
            make.bottom.equalTo(self.cityButton).offset(-4);
            make.leading.equalTo(self.cityButton.snp.trailing)
            make.width.equalTo(1)
        }
        
        verticalLine2.snp.makeConstraints { (make) in
            make.top.equalTo(self.musicButton).offset(4);
            make.bottom.equalTo(self.musicButton).offset(-4);
            make.leading.equalTo(self.musicButton.snp.trailing)
            make.width.equalTo(1)
        }
        
        horizontalLine.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.cityButton)
            make.height.equalTo(1)
        }
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }
    
    private func createSeparateLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return line
    }
}
