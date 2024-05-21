//
//  ViewController.swift
//  User-TraK
//
//  Created by MANIKANDAN RAJA on 17/05/24.
//

import UIKit
import Alamofire
import CoreData
import MapKit
import FLAnimatedImage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var nodataimg: UIImageView!
    @IBOutlet weak var liveGif: FLAnimatedImageView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var mapVw: MKMapView!
    let locationManager = CLLocationManager()
    var Locality = String()
    var subLocality = String()
    var region = String()
    
    
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userListTbl: UITableView!
    var user: Users? // Property to hold the user being edited, nil for new user

    var users: [Users] = []
    var viewModel: UserViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start monitoring internet connection
             NetworkMonitor.shared.delegate = self
             NetworkMonitor.shared.startMonitoring()
        
        // Do any additional setup after loading the view.
        // Request permission to use location services
               locationManager.requestWhenInUseAuthorization()
               
               // Set up the map view
               mapVw.delegate = self

               mapVw.showsUserLocation = true
        
        // Start updating the user's location
               locationManager.delegate = self
               locationManager.startUpdatingLocation()
        
        
        userListTbl.reloadData()
        userListTbl.rowHeight = UITableView.automaticDimension
            userListTbl.estimatedRowHeight = 100.0 // Estimated height
        viewModel = UserViewModel()
        
        fetchUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateTableViewHeight()
        userListTbl.estimatedRowHeight = 50.0 // Estimated height

        fetchUsers()

        userListTbl.reloadData()
    }

    func fetchUsers() {
        viewModel.fetchUsers { [weak self] users in
            guard let self = self else { return }
            
            if let users = users, !users.isEmpty {
                nodataimg.isHidden = true
                self.userListTbl.isHidden = false
                self.fetchAndShowSavedUsers()
                self.updateTableViewHeight()

            } else {
                nodataimg.isHidden = false
                self.userListTbl.isHidden = true
                print("Failed to fetch users or no users found")
       //         displayAlert(message: " User Data is Empty")

            }
        }
    }
    private func fetchAndShowSavedUsers() {
        viewModel.fetchSavedUsers { [weak self] savedUsers in
            guard let self = self else { return }
            
            if let savedUsers = savedUsers {
                self.users = savedUsers
                DispatchQueue.main.async {
                    self.userListTbl.reloadData()
                }
            } else {
                print("No saved users found in Core Data")
            }
        }
    }
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, hh:mm a"
        
        return dateFormatter.string(from: Date())
    }

    func updateTableViewHeight() {
            userListTbl.layoutIfNeeded() // Ensure the layout is up to date
        //    let contentHeight = userListTbl.contentSize.height
            let calculatedHeight: CGFloat
            let userCount = users.count

            if userCount == 0 {
                calculatedHeight = 200 // Fixed height when no users are present
                nodataimg.isHidden = false
                tableViewHeightConstraint.constant = calculatedHeight

            } else {
                nodataimg.isHidden = true
                calculatedHeight = CGFloat(userCount * 50)
                tableViewHeightConstraint.constant = min(calculatedHeight, 300)
       //         calculatedHeight = max(50, min(contentHeight, 300)) // Minimum 50 when users are present, max 300
            }
            print("Updated table view height to \(tableViewHeightConstraint.constant)")
        }
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "User Trak", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
   
    // MARK: - CLLocationManagerDelegate
       
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 //       activityIndicator.startAnimating()
        
        guard let location = locations.last else {
            return
        }
        
        let regionRadius: CLLocationDistance = 3000 // Adjust the radius as needed
        
        // Define the region around the user's location
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: regionRadius,
                                        longitudinalMeters: regionRadius)
        
        // Set the map view's region to the defined region
        mapVw.setRegion(region, animated: true)
        
        // Stop updating the location once it's centered on the user
        locationManager.stopUpdatingLocation()
        
        // Use the user's current location (latitude and longitude) as needed
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        UserDefaults.standard.set(latitude, forKey: "lat")
        UserDefaults.standard.set(longitude, forKey: "lon")
        
        print("Latitude: \(latitude), Longitude: \(longitude)")
        locationManager.stopUpdatingLocation()
        // Perform reverse geocoding to get the city name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
               var addressString = ""
                
                // Region
                if let region = placemark.administrativeArea {
                    addressString += region + ", "
                    self.region = region
                }
                // Locality
                if let locality = placemark.locality {
                    addressString += locality + ", "
                    self.Locality = locality

                }
                
                // Sublocality
                if let subLocality = placemark.subLocality {
                    addressString += subLocality
                    self.subLocality = subLocality

                }
                                
                    DispatchQueue.main.async {
                        self.cityLbl.text = self.Locality + " ," + self.region
                        self.currentTimeLbl.text = self.getCurrentTime()
                        
                        // Ensure the file exists and is properly added to the project
                              if let path = Bundle.main.path(forResource: "gps", ofType: "gif") {
                                  do {
                                      let url = URL(fileURLWithPath: path)
                                      let gifData = try Data(contentsOf: url)
                                      let animatedImage = FLAnimatedImage(animatedGIFData: gifData)
                                      self.liveGif.animatedImage = animatedImage
                                  } catch {
                                      print("Failed to load GIF data: \(error.localizedDescription)")
                                  }
                              } else {
                                  print("GIF file not found.")
                              }
                          
                        
 //                       self.activityIndicator.stopAnimating()
                        
                    }
                    
                }
                
            }
            
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath) as! UserListTableViewCell
        let user = users[indexPath.row]
        cell.nameLabel.text = user.name
        cell.mobileLabel.text = user.mobile
        cell.emailLabel.text = user.email
        cell.genderLabel.text = user.gender
        
        cell.editAction = { [weak self] in
            self?.navigateToEditViewController(with: user)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // Adjust the height as needed
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let userToDelete = users[indexPath.row]
            let user = User(name: userToDelete.name ?? "", mobile: userToDelete.mobile ?? "", email: userToDelete.email ?? "", gender: userToDelete.gender ?? "", _id: userToDelete.id ?? "")
            
            viewModel.deleteUser(user) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.users.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.updateTableViewHeight()
                        self.displayAlert(message: "User Detail Deleted Successfully")

                    }
                } else {
                    self.displayAlert(message: "User Detail Not Deleted Api Request Limit Exceeded")
                }
            }
        }
    }
    
    private func navigateToEditViewController(with user: Users) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "editVC") as? EditViewController {
            editVC.user = user
            editVC.viewModel = viewModel
            navigationController?.pushViewController(editVC, animated: true)
        }
    }
    @IBAction func gpsBtn(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    @IBAction func NewUserBtn_Act(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Ensure the storyboard identifier is correct
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "editVC") as? EditViewController else {
            print("Error: Could not instantiate view controller with identifier 'EditViewController'")
            return
        }
        
        // Pass the user object (nil for new user) and viewModel to the editVC
        editVC.user = user
        editVC.viewModel = viewModel
        
        // Ensure the current view controller is part of a navigation controller
        guard let navigationController = self.navigationController else {
            print("Error: Navigation controller not found")
            return
        }
        
        // Push the editVC onto the navigation stack
        navigationController.pushViewController(editVC, animated: true)
        print("Navigating to EditViewController")
    }

}

extension ViewController: NetworkStatusDelegate {
    func internetConnected() {
        print("Internet Connected")    }
    
    func internetDisconnected() {
        displayAlert(message: "Check Your Internet Connection ")
        
    }
}
