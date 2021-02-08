//
//  LocationViewController.swift
//  CheckIn
//
//  Created by Dimitar on 25.1.21.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD

protocol LocationDelegate: class {
    func didPostItem(item: Feed)
}
class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    
    let manager = CLLocationManager()
    var pickedImage: UIImage?
    weak var delegate: LocationDelegate?
    var feedItems = [Feed]()
    var moment = Feed()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setTitle()
        setBackButton()
        setCheckInButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
        
    }
    
    func setTitle() {
        title = "Your Location"
        let titleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes as [NSAttributedString.Key : Any]
    }
    
    func setBackButton() {
        let back = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        back.setImage(UIImage(named: "BackButton"), for: .normal)
        back.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setCheckInButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 14))
        button.setTitle("Check In", for: .normal)
        let titleColor = UIColor.systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(self, action: #selector(onCheckIn), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    
    @objc func onCheckIn() {
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        manager.delegate = self
    }
    
    func uploadImage() {
        mapImage.image = pickedImage
        
        
        guard let localUser = DataStore.shared.localUser else {
            return
        }
        guard let pickedImage = pickedImage else {
            showErrorWith(title: "Error", msg: "Image not found")
            return
        }
        guard let location = location.text else {
            showErrorWith(title: "Error", msg: "No location description")
            return
        }
        guard let latitude = latitude.text else {
            showErrorWith(title: "Error", msg: "No location description")
            return
        }
        guard let longitude = longitude.text else {
            showErrorWith(title: "Error", msg: "No location description")
            return
        }
        moment.location = location
        moment.creatorId = localUser.id
        moment.createdAt = Date().toMiliseconds()
        moment.latitude = latitude
        moment.longitude = longitude
        SVProgressHUD.show()
        let uuid = UUID().uuidString
        DataStore.shared.uploadImage(image: pickedImage, itemId: uuid, isUserImage: false) { (url, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                print(error.localizedDescription)
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let url = url {
                self.moment.imageUrl = url.absoluteString
                DataStore.shared.createFeedItem(item: self.moment) { (feed, error) in
                    if let error = error {
                        self.showErrorWith(title: "Error", msg: error.localizedDescription)
                        return
                    }
                    self.delegate?.didPostItem(item: self.moment)
                }
                return
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[0] as CLLocation
            manager.stopUpdatingLocation()
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.centerCoordinate = location.coordinate
        mapView.setCenter(location.coordinate, animated: true)
        mapView.setRegion(region, animated: false)
        mapView.mapType = .standard
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count > 0 {
                let placemark = placemarks![0]
                self.location.text = "\(placemark.name!), \(placemark.administrativeArea!), \(placemark.country!)"
                self.latitude.text = "\(location.coordinate.latitude)"
                self.longitude.text = "\(location.coordinate.longitude)"
            }
        }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        let options = MKMapSnapshotter.Options()
        options.region = mapView.region
        options.size = CGSize(width: 343.0, height: 175.0)
        options.scale = UIScreen.main.scale
        let rect = mapView.bounds
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("Snapshot error: \(error!.localizedDescription)")
                return
            }
            let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                
                    snapshot.image.draw(at: .zero)
                    let pinView = MKPinAnnotationView(annotation: pin, reuseIdentifier: nil)
                    let pinImage = pinView.image
                    var point = snapshot.point(for: location.coordinate)
                    if rect.contains(point) {
                        point.x -= pinView.bounds.width / 2
                        point.y -= pinView.bounds.height / 2
                        point.x += pinView.centerOffset.x
                        point.y += pinView.centerOffset.y
                        pinImage?.draw(at: point)
                    }
            }
            self.pickedImage = image
            self.uploadImage()
        }
    }
}
