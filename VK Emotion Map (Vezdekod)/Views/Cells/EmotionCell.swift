//
//  EmotionCell.swift
//  VK Emotion Map (Vezdekod)
//
//  Created by Alex Yatsenko on 18.09.2020.
//  Copyright © 2020 AlexislogS. All rights reserved.
//

import UIKit

final class EmotionCell: UICollectionViewCell {
    
    @IBOutlet private weak var emotionLabel: UILabel!
    @IBOutlet private weak var themeLabel: UILabel!
    @IBOutlet private weak var themeTitleLabel: UILabel!
    
    static let reuseID = "emotionCell"
    
    func configure(with theme: Theme) {
        emotionLabel.text = String(theme.emotion.prefix(1))
        themeLabel.text = theme.themeEmotion
        themeTitleLabel.text = theme.title
    }
}
