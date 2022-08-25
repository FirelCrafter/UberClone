//
//  MenuHeader.swift
//  uberClone
//
//  Created by Михаил Щербаков on 25.08.2022.
//

import UIKit

class MenuHeader: UIView {
    
    //MARK: Properties
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        backgroundColor = .backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Selectors
    
}
