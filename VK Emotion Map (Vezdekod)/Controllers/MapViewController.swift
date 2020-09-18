//
//  ViewController.swift
//  VK Emotion Map (Vezdekod)
//
//  Created by Alex Yatsenko on 18.09.2020.
//  Copyright © 2020 AlexislogS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

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
    
    private let regionInMeters = 10_000.0
    private var defaultEmotionsViewHight: CGFloat = 0
    private let themes = Themes.getThemes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSPBMap()
        addAnnotations()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDidShow(notification:)),
                                               name: UITextField.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDidHide),
                                               name: UITextField.keyboardDidHideNotification,
                                               object: nil)
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
    
    private func showSPBMap() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("St. Petersburg") { (placemarks, error) in
            if let location = placemarks?.first?.location?.coordinate {
                self.emotionMap.setRegion(MKCoordinateRegion(center: location, latitudinalMeters: self.regionInMeters, longitudinalMeters: self.regionInMeters), animated: true)
            }
        }
    }
    
    private func addAnnotations() {
        var annotations = [MKPointAnnotation]()
        for theme in themes {
            let annotation = MKPointAnnotation()
            annotation.title = theme.themeEmotion
            annotation.subtitle = theme.title
            annotation.coordinate = theme.coordinate
            annotations.append(annotation)
        }
        emotionMap.showAnnotations(annotations, animated: true)
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
}

    // MARK: - UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

    // MARK: - UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionCell.reuseID, for: indexPath) as! EmotionCell
        let theme = themes[indexPath.item]
        cell.configure(with: theme)
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension MapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 96)
    }
}

    // MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationID) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: Constants.annotationID)
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        if let title = annotation.title {
            annotationView?.image = title?.emojiToImage()?.roundedImage
        }
        
        return annotationView
    }
}
