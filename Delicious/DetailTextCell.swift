//
//  DetialTextCell.swift
//  Delicious
//
//  Created by Fomin Nickolai on 11/22/16.
//  Copyright © 2016 Fomin Nickolai. All rights reserved.
//

import UIKit

class DetailTextCell: DetailBaseCell {
    
    var textCell: String? {
        didSet {
            textView.text = textCell
        }
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.text = "1. Blend the ingredients for pesto in a processor and keep aside."
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
    }()
    
    let titleCellTopView: UILabel = {
        let label = UILabel()
        label.text = "Ingridients"
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        label.backgroundColor = UIColor(red:1,  green:0.404,  blue:0.384, alpha:1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        layer.cornerRadius = 8.0
        clipsToBounds = true
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundView = blurEffectView
        
        addSubview(titleCellTopView)
        addSubview(textView)
        
        titleCellTopView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleCellTopView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleCellTopView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleCellTopView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        textView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        textView.topAnchor.constraint(equalTo: titleCellTopView.bottomAnchor, constant: 15).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor, constant: -48).isActive = true
    }
    
}
