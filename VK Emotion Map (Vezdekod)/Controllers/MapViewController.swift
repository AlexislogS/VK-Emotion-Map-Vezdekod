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

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var emotionsViewHight: NSLayoutConstraint! {
        didSet {
            defaultEmotionsViewHight = emotionsViewHight.constant
        }
    }
    
    @IBOutlet private weak var topEmotionLabel: UILabel!
    @IBOutlet private weak var emotionMap: MKMapView!
    @IBOutlet private weak var emotionCollectionView: UICollectionView!
    @IBOutlet private weak var emotionSearch: UISearchBar!
    
    private var defaultEmotionsViewHight: CGFloat = 0
    private var annotations = [MKPointAnnotation]()
    private var defaultRegion: MKCoordinateRegion!
    private var previousRow: Int?
    private let themes = Themes.getThemes
    private var filteredThemes = [Theme]()
    
    private var isFiltering: Bool {
        guard let text = emotionSearch.text else { return false }
        return !text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCity(name: "St. Petersburg")
        addAnnotations()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDidShow(notification:)),
                                               name: UITextField.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDidHide),
                                               name: UITextField.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueID.showThemeFeed.rawValue,
            let annotation = emotionMap.selectedAnnotations.first,
            let themeVC = segue.destination as? ThemeViewController {
            if let title = annotation.subtitle {
                themeVC.title = title
            }
        }
    }
    
    @IBAction func closeMap() {
        navigationController?.popViewController(animated: true)
    }
    
    private func addAnimationToEmotionView(from: CATransitionSubtype,
                                           completion: () -> Void) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = from
        self.bottomView.layer.add(transition, forKey: kCATransition)
        completion()
    }
    
    private func showCity(name: String) {
        CLGeocoder().geocodeAddressString(name) { (placemarks, error) in
            if let location = placemarks?.first?.location?.coordinate {
                let regionInMeters = 10_000.0
                self.defaultRegion = MKCoordinateRegion(center: location,
                                                       latitudinalMeters: regionInMeters,
                                                       longitudinalMeters: regionInMeters)
                self.emotionMap.setRegion(self.defaultRegion,
                                          animated: true)
            }
        }
    }
    
    private func addAnnotations() {
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
        filterPersons(for: searchBar.text!)
    }
    
    private func filterPersons(for title: String) {
        filteredThemes = themes.filter {
            $0.title.lowercased().contains(title.lowercased())
        }
        emotionCollectionView.reloadData()
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension MapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 96)
    }
}

    // MARK: - UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? filteredThemes.count : themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionCell.reuseID, for: indexPath) as! EmotionCell
        let theme = isFiltering ? filteredThemes[indexPath.item] : themes[indexPath.item]
        cell.configure(with: theme)
        return cell
    }
}

    // MARK: - UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = isFiltering ? filteredThemes[indexPath.item] : themes[indexPath.item]
        if topView.isHidden {
            topView.isHidden = false
        }
        topEmotionLabel.text = theme.emotion
        if let annotation = annotations.filter({ $0.subtitle == theme.title }).first {
            if previousRow == indexPath.row {
                emotionMap.selectAnnotation(annotation, animated: true)
                return
            }
            let rangeInMeters = 1000.0
            let region = MKCoordinateRegion(center: annotation.coordinate,
                                            latitudinalMeters: rangeInMeters,
                                            longitudinalMeters: rangeInMeters)
            if emotionMap.region.center.latitude != defaultRegion?.center.latitude &&
                emotionMap.region.center.longitude != defaultRegion?.center.longitude {
                emotionMap.setRegion(self.defaultRegion,
                                     animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.emotionMap.setRegion(region, animated: true)
            }
        }
        previousRow = indexPath.row
    }
}

    // MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseID.emotionAnnotationView.rawValue) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: ReuseID.emotionAnnotationView.rawValue)
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        if let title = annotation.title {
            annotationView?.image = title?.emojiToImage()?.roundedImage
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: SegueID.showThemeFeed.rawValue, sender: nil)
    }
}
