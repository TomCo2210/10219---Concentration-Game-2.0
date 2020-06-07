//
//  HighScoresViewController.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 31/05/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HighScoresViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var HighScores_SEGCTRL_level: UISegmentedControl!
    @IBOutlet weak var HighScores_TBLV_list: UITableView!
    @IBOutlet weak var HighScores_MAP_map: MKMapView!
    var highScoresToShow = [HighScore]()
    var segmentedInitialIndex :Int = 0
    
    var locationManager:CLLocationManager!
    var location:Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true,animated: false)
        HighScores_SEGCTRL_level.selectedSegmentIndex = segmentedInitialIndex
        HighScores_TBLV_list.delegate = self
        HighScores_TBLV_list.dataSource = self
        LevelPicked(HighScores_SEGCTRL_level)
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
    
    
    //MARK: - SegmentedControl Picker
    @IBAction func LevelPicked(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            highScoresToShow = readFromUserDefaults(level: "Easy")
            print("Easy")
            break
        case 1:
            highScoresToShow = readFromUserDefaults(level: "Medium")
            print("Medium")
            break
        case 2:
            highScoresToShow = readFromUserDefaults(level: "Hard")
            print("Hard")
            break
        default:
            highScoresToShow = readFromUserDefaults(level: "Easy")
            print("defaultEasy")
        }
        HighScores_TBLV_list.reloadData()
    }
    
   // MARK: - MANGE STROAGE
    func writeToUserDefaults(highScores: [HighScore],level :String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(fromListToJson(list: highScores), forKey: level)
    }
    
    func readFromUserDefaults(level:String) -> [HighScore]{
        let userDefaults = UserDefaults.standard
        if let highScores: [HighScore] = fromJsonToList(json: userDefaults.string(forKey: level) ?? ""){
            print(highScores)
            return highScores
        }
        return [HighScore]()
    }
    
    // MARK: - Add To TableView
    func addNewHighScore(newHighScore: HighScore, level :String){
        var highScores = readFromUserDefaults(level: level)
        if (highScores.count == 10){
            highScores.remove(at: highScores.count - 1)
        }
        newHighScore.gameLocation = location ?? Location()
        highScores.append(newHighScore)
        writeToUserDefaults(highScores: highScores.sorted(by: {$0.timeElapsed < $1.timeElapsed}), level: level)
        self.highScoresToShow = highScores
    }
    
    // MARK: - Navigation
     @IBAction func backButtonPressed(_ sender: Any) {
         self.navigationController?.popToRootViewController(animated: true)
     }

    //MARK: - JSON Convertion
    func fromListToJson(list: [HighScore]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(list)
        let jsonString: String = String(data: data, encoding: .utf8)!
        return jsonString
    }
    
    func fromJsonToList(json: String) -> [HighScore]? {
        let decoder = JSONDecoder()
        if json == "" {
            return [HighScore]()
        }else{
            let data: [HighScore]
            let convertedData: Data = json.data(using: .utf8)!
            data = try! decoder.decode([HighScore].self,from: convertedData)
            return data
        }
    }
    
    //MARK:- CLLocationManagerDelegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let mUserLocation = locations.last {

        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        HighScores_MAP_map.setRegion(mRegion, animated: true)
            // Get user's Current Location and Drop a pin
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
        mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
            HighScores_MAP_map.addAnnotation(mkAnnotation)
        print("Location!")
        }}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    
    //MARK:- Intance Methods
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    //MARK: - Location String
       func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
           var currentLocationStr = ""
           let geoCoder = CLGeocoder()
           let location = CLLocation(latitude: mLattitude, longitude: mLongitude)
           
           geoCoder.reverseGeocodeLocation(location) { (placemarksArray, error) in
               print(placemarksArray!)
               if (error) == nil {
                   if placemarksArray!.count > 0 {
                       let placemark = placemarksArray?[0]
                       currentLocationStr = "\(placemark?.subThoroughfare ?? ""), \(placemark?.thoroughfare ?? ""), \(placemark?.locality ?? ""), \(placemark?.subLocality ?? ""), \(placemark?.administrativeArea ?? ""), \(placemark?.country ?? "")"
                   }
               }
           }
           return currentLocationStr
       }
}



// MARK: - PROTOCOL FOR TABLE-VIEW
extension HighScoresViewController :UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScoresToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell :HighScoresTableViewCell? = self.HighScores_TBLV_list.dequeueReusableCell(withIdentifier: "highScoreCell") as? HighScoresTableViewCell
        
        cell?.highScores_LBL_rank.text = "\(indexPath.row + 1))"
        
        cell?.highScores_LBL_name.text = self.highScoresToShow[indexPath.row].playerName
        
        let seconds = String(format: "%02d", (self.highScoresToShow[indexPath.row].timeElapsed%60))
        let minutes = String(format: "%02d", self.highScoresToShow[indexPath.row].timeElapsed/60)
        cell?.highScores_LBL_elapsedTime.text = "\(minutes):\(seconds)"
        
        cell?.highScores_LBL_location.text = setUsersClosestLocation( mLattitude: self.highScoresToShow[indexPath.row].gameLocation.latitude, mLongitude: self.highScoresToShow[indexPath.row].gameLocation.longitude)
        
        cell?.highScores_LBL_date.text = self.highScoresToShow[indexPath.row].dateOfGame
        
        if(cell == nil){
            cell = HighScoresTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "highScoreCell")
        }
        return cell!
    }
    
    // MARK: - TESTING
    func clearStroateTestingOnly(){
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
    }
    
    func checkForHighScoreInLevel(timeElapsed:Int,level :String) -> Bool {
        let highScores = readFromUserDefaults(level: level)
      
        return ((highScores.count != 10) ? true : (highScores[highScores.count - 1].timeElapsed>timeElapsed))
    }
}

