//
//  HomeViewController.swift
//  CheckIn
//
//  Created by Deniz Adil on 14.1.21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SVProgressHUD
import CoreLocation
import MapKit



class HomeViewController: UIViewController, CLLocationManagerDelegate, LocationDelegate {
    
    @IBOutlet weak var noCheckIns: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var onPost: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapImage: UIImageView!
    
    var refreshControl = UIRefreshControl()
   
    let manager = CLLocationManager()
    var pickedImage: UIImage?
    var feedItems = [Feed]()
    var moment = Feed()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        setTitle()
        setLogOutButton()
        //customizeButton(onPost: onPost)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
        fetchFeedItems()
    }
    
    @IBAction func onPost(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)

    }
    func didPostItem(item: Feed) {
        navigationController?.popViewController(animated: true)
        self.feedItems.append(item)
        sortAndReload()
    }
    func setTitle() {
        title = "Home Screen"
        let titleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes as [NSAttributedString.Key : Any]
    }
//
//    func customizeButton(onPost: UIButton) {
//        onPost.layer.shadowColor = UIColor(red: 0.102, green: 0.102, blue: 0.102, alpha: 0.50).cgColor
//        onPost.layer.shadowOpacity = 0.8
//        onPost.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
//    }
    
    func setLogOutButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 14))
        button.setTitle("LogOut", for: .normal)
        let titleColor = UIColor.systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(self, action: #selector(onLogOut), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "MyCheckInsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCheckInsCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionView.frame.width, height: 343)
            layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 260)
        }
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView.refreshControl = self.refreshControl
    }
    @objc func onLogOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "WelcomeViewController", sender: nil)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        fetchFeedItems(isRefresh: true)
    }
    
    private func fetchFeedItems(isRefresh: Bool = false) {
        SVProgressHUD.show()
        if isRefresh {
            feedItems.removeAll()
        }
        DataStore.shared.fetchFeedItems { (feed, error) in
            SVProgressHUD.dismiss()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            self.feedItems.removeAll()
            if let feed = feed {
                self.feedItems = feed
                if self.feedItems.count == 0 {
                    self.noCheckIns.isHidden = false //true
                } else {
                    self.noCheckIns.isHidden = true //false
                }
                self.sortAndReload()
            }
        }
    }
    
    func sortAndReload() {
        self.feedItems.sort { (feedOne, feedTwo) -> Bool in
            guard let oneDate = feedOne.createdAt else { return false }
            guard let twoDate = feedTwo.createdAt else { return false }
            return oneDate > twoDate
        }
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCheckInsCollectionViewCell", for: indexPath) as! MyCheckInsCollectionViewCell
            let feed = feedItems[indexPath.row]
        guard let user = DataStore.shared.localUser else { return cell }
        cell.setupCell(feedItem: feed, user: user)
            return cell
    }
}
