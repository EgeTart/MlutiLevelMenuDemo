//
//  MultiLevelMenu.swift
//  MultiLevelMenuDemo
//
//  Created by Passaction on 2017/8/11.
//  Copyright © 2017年 passaction. All rights reserved.
//

import UIKit

@objc protocol MultiLevelMenuDataSource: NSObjectProtocol {
    @objc func numberOfLevel(of multiLevelMenu: MultiLevelMenu) -> Int
    @objc func firstLevelItems(of multiLevelMenu: MultiLevelMenu) -> [LeveItemProtocol]?
}

@objc protocol MultiLevelMenuDelegate: NSObjectProtocol {
    
    @objc optional func multiLevelMenu(multiLevelMenu: MultiLevelMenu, backgroundColorForLevel level: Int) -> UIColor
    @objc optional func multiLevelMenu(multiLevelMenu: MultiLevelMenu, widthRatioForLevel level: Int) -> CGFloat
    
    @objc optional func multiLevelMenu(multiLevelMenu: MultiLevelMenu, didSelectedLastLevel selectedLevelItems: [LeveItemProtocol])
}

fileprivate class LevelItemCell: UITableViewCell {
    
    lazy var levelNamelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        
        // 布局label
        self.contentView.addSubview(levelNamelabel)
        levelNamelabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(8, 12, 8, 12))
        }
        
        // 添加紫色选中效果
        let view = UIView()
        view.backgroundColor = UIColor(red: 198 / 255.0, green: 165 / 255.0, blue: 223 / 255.0, alpha: 0.3)
        self.selectedBackgroundView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MultiLevelMenu: UIView {
    
    //MARK: - 公开变量
    weak var delegate: MultiLevelMenuDelegate? {
        didSet {
            guard let delegate = delegate else {
                return
            }
            
            if delegate.responds(to: #selector(MultiLevelMenuDelegate.multiLevelMenu(multiLevelMenu:backgroundColorForLevel:))) {
                changeTableViewBackgroudColor()
            }
            
            if delegate.responds(to: #selector(MultiLevelMenuDelegate.multiLevelMenu(multiLevelMenu:backgroundColorForLevel:))) {
                remakeTableViewConstraints()
            }
        }
    }
    
    weak var dataSource: MultiLevelMenuDataSource? {
        didSet {
            guard let dataSource = dataSource else {
                return
            }
            
            numberOfLvel = dataSource.numberOfLevel(of: self)
            firstLevelItems = dataSource.firstLevelItems(of: self)
            handleLevelData()
            createMenuTableView()
        }
    }
    
    var isShowed = false
    
    //MARK: - 私有变量
    fileprivate let LevelItemCellReuseIdentifier = "LevelItemCellReuseIdentifier"
    fileprivate lazy var numberOfLvel = 0
    fileprivate lazy var menuTableViews = [UITableView]()
    
    fileprivate var firstLevelItems: [LeveItemProtocol]?
    fileprivate lazy var selectedLevelItems = [LeveItemProtocol?]()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 创建table view
    private func createMenuTableView() {
        for level in 0..<self.numberOfLvel {
            let tableView = UITableView()
            tableView.register(LevelItemCell.self, forCellReuseIdentifier: LevelItemCellReuseIdentifier)
            tableView.tag = 100 + level
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 40
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorColor = UIColor(white: 0.9, alpha: 1.0)
            tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            tableView.dataSource = self
            tableView.delegate = self
            
            menuTableViews.append(tableView)
        }
        
        configureLayout()
    }
    
    // 布局table view
    private func configureLayout() {
        self.addSubview(containerView)
        for (index, tableView) in menuTableViews.enumerated() {
            containerView.addSubview(tableView)
            
            tableView.snp.makeConstraints({ (make) in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(1.0 / Double(self.numberOfLvel))
                
                if index == 0 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(self.menuTableViews[index - 1].snp.trailing)
                }
            })
        }
        
        containerView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
    }
    
    private func handleLevelData() {
        guard let firstLevelItems = firstLevelItems else {
            return
        }
        
        for level in 0..<numberOfLvel {
            if selectedLevelItems.count == 0 {
                selectedLevelItems.append(firstLevelItems[0])
            } else {
                if let nextLevelItems = selectedLevelItems[level - 1]?.nextLevelItems {
                    selectedLevelItems.append(nextLevelItems[0])
                } else {
                    selectedLevelItems.append(nil)
                }
            }
        }
    }
    
    private func changeTableViewBackgroudColor() {
        for level in 0..<numberOfLvel {
            let backgroundColor = self.delegate!.multiLevelMenu!(multiLevelMenu: self, backgroundColorForLevel: level)
            menuTableViews[level].backgroundColor = backgroundColor
        }
    }
    
    private func remakeTableViewConstraints() {
        for level in 0..<numberOfLvel {
            let widthRatio = self.delegate!.multiLevelMenu!(multiLevelMenu: self, widthRatioForLevel: level)
            let tableView = menuTableViews[level]
            
            tableView.snp.remakeConstraints({ (make) in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(widthRatio)
                
                if level == 0 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(self.menuTableViews[level - 1].snp.trailing)
                }
            })
        }
    }
    
    func presnt(from view: UIView) {
        var tmpSuperView = view
        
        // 寻找最上级view
        while tmpSuperView.superview != nil {
            tmpSuperView = tmpSuperView.superview!
        }
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        // 进行坐标变化，得到控件左下角相对于最上级view的坐标
        var presentPoint: CGPoint
        if view.superview == tmpSuperView {
            presentPoint = CGPoint(x: view.frame.minX, y: view.frame.maxY)
        } else {
            presentPoint = tmpSuperView.convert(CGPoint(x: view.frame.minX, y: view.frame.maxY), from: view)
        }
        
        self.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(presentPoint.y)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 1.改变约束让containerView的位置刚好在MultiLevelMenu控件的上方，并使约束立即生效
        self.containerView.snp.remakeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
            make.bottom.equalTo(self.snp.top)
        }
        self.layoutIfNeeded()
        self.alpha = 0.0
        
        // 2.恢复containerView到原来的位置，使用动画让约束逐步生效
        self.containerView.snp.remakeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
        
        UIView.animate(withDuration: CATransaction.animationDuration()) { 
            self.alpha = 1.0
            self.layoutIfNeeded()
        }
        
        isShowed = true
    }
    
    func dismiss(animated: Bool) {
        if animated {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: { 
                self.alpha = 0.0
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
        
        isShowed = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}

extension MultiLevelMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let level = tableView.tag - 100
        if level == 0 {
            return firstLevelItems?.count ?? 0
        } else {
            return selectedLevelItems[level - 1]?.nextLevelItems?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let level = tableView.tag - 100
        
        var levelItem: LeveItemProtocol?
        if level == 0 {
            levelItem = firstLevelItems?[indexPath.row]
        } else {
            levelItem = selectedLevelItems[level - 1]?.nextLevelItems?[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LevelItemCellReuseIdentifier, for: indexPath) as! LevelItemCell
        
        cell.levelNamelabel.text = levelItem?.levelName
        
        return cell
    }
}

extension MultiLevelMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let level = tableView.tag - 100
        updateNextLevelItems(selectedLevel: level, on: indexPath)
        
        // 检查是否选中了最后一个级别，并对delegate和可选方法进行判空操作
        if (selectedLevelItems[level]?.nextLevelItems == nil)
            && (delegate != nil)
            && (delegate!.responds(to: #selector(MultiLevelMenuDelegate.multiLevelMenu(multiLevelMenu:didSelectedLastLevel:)))) {
            delegate?.multiLevelMenu!(multiLevelMenu: self, didSelectedLastLevel: selectedLevelItems.filter{ $0 != nil } as! [LeveItemProtocol])
            dismiss(animated: true)
        }
    }
    
    // 选中某一级别，需要更新对应的下一级别
    func updateNextLevelItems(selectedLevel: Int, on indexPath: IndexPath) {
        // 更新对应的下一级别
        if selectedLevel == 0 {
            selectedLevelItems[0] = firstLevelItems?[indexPath.row]
        } else {
            selectedLevelItems[selectedLevel] = selectedLevelItems[selectedLevel - 1]?.nextLevelItems?[indexPath.row]
        }
        
        // 后续选中的下一级别默认为第一项
        for level in (selectedLevel+1)..<numberOfLvel {
            selectedLevelItems[level] = selectedLevelItems[level - 1]?.nextLevelItems?.first
        }
        
        // 刷新后续的tableview
        for level in (selectedLevel+1)..<numberOfLvel {
            menuTableViews[level].reloadData()
        }
    }
}
