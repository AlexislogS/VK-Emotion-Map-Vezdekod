//
//  NewsViewController.swift
//  VK Emotion Map (Vezdekod)
//
//  Created by Alex Yatsenko on 18.09.2020.
//  Copyright © 2020 AlexislogS. All rights reserved.
//

import UIKit

final class NewsViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
