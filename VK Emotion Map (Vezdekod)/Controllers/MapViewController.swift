//
//  ViewController.swift
//  VK Emotion Map (Vezdekod)
//
//  Created by Alex Yatsenko on 18.09.2020.
//  Copyright © 2020 AlexislogS. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {

    @IBOutlet weak var emotionView: UIView!
    @IBOutlet private weak var emotionsViewHight: NSLayoutConstraint! {
        didSet {
            defaultEmotionsViewHight = emotionsViewHight.constant
        }
    }
    @IBOutlet private weak var emotionMap: MKMapView!
    @IBOutlet private weak var emotionCollectionView: UICollectionView!
    @IBOutlet private weak var emotionSearch: UISearchBar!
    
    private var defaultEmotionsViewHight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDidShow(notification:)),
                                               name: UITextField.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDidHide),
                                               name: UITextField.keyboardDidHideNotification,
                                               object: nil)
    }
    
    @objc private func handleDidShow(notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UITextField.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addAnimationToEmotionView(from: .fromTop) {
                self.emotionsViewHight.constant = self.defaultEmotionsViewHight + keyboardFrame.height
            }
        }
    }
    
    @objc private func handleDidHide() {
        addAnimationToEmotionView(from: .fromBottom) {
            self.emotionsViewHight.constant = self.defaultEmotionsViewHight
        }
    }
    
    private func addAnimationToEmotionView(from: CATransitionSubtype,
                                           completion: () -> Void) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = from
        self.emotionView.layer.add(transition, forKey: kCATransition)
        completion()
    }
}

    // MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

