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

class HighScoresViewController: UIViewController {
    
    @IBOutlet weak var HighScores_SEGCTRL_level: UISegmentedControl!
    @IBOutlet weak var HighScores_TBLV_list: UITableView!
    @IBOutlet weak var HighScores_MAP_map: MKMapView!
    
    var highScoresToShow = [HighScore]()
    
    var segmentedInitialIndex :Int = 0
    
    var newHighScore:HighScore?
    var level:String?
    
    var locationManager:CLLocationManager = CLLocationManager()
    var location:Location?
    
    var memoryIO = MemoryIO()
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //REMOVE "//" IF YOU WANT TO CLEAN HIGHSCORES SAVED IN MEMORY.
        memoryIO.clearUserDefaults()
        
        //hide nav bar:
        navigationController?.setNavigationBarHidden(true,animated: false)
        
        //list protocols setters
        HighScores_TBLV_list.delegate = self
        HighScores_TBLV_list.dataSource = self
        
        //select level of highscores to show:
        HighScores_SEGCTRL_level.selectedSegmentIndex = segmentedInitialIndex
        LevelPicked(HighScores_SEGCTRL_level)
        
        //if got here through the game -> need to add new highscore -> need to determine location
        if (newHighScore != nil && level != nil){ determineCurrentLocation() }
        
        //if it is the first time running this app, no highscores to read, no location to set on map.
        if !highScoresToShow.isEmpty {
            HighScores_TBLV_list.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.top)
            createRegion(
                latitude: highScoresToShow[0].gameLocation.latitude,
                longitude:highScoresToShow[0].gameLocation.longitude)
        }
    }
    
    //MARK: - SegmentedControl Picker
    @IBAction func LevelPicked(_ sender: UISegmentedControl) {
        highScoresToShow = memoryIO.readFromUserDefaults(level: sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        print("HighScores for level \(sender.titleForSegment(at: sender.selectedSegmentIndex)!) Loaded")
        HighScores_TBLV_list.reloadData()
    }
    
    // MARK: - Add To TableView
    func addNewHighScore(newHighScore: HighScore, level :String){
        var highScores = memoryIO.readFromUserDefaults(level: level)
        if (highScores.count == 10){
            highScores.remove(at: highScores.count - 1)
        }
        highScores.append(newHighScore)
        highScores.sort(by: {$0.timeElapsed < $1.timeElapsed})
        memoryIO.writeToUserDefaults(highScores: highScores, level: level)
        self.highScoresToShow = highScores
        HighScores_TBLV_list.reloadData()
    }
    
    //MARK: - HighScore Check
    func checkForHighScoreInLevel(timeElapsed:Int,level :String) -> Bool {
        let highScores = memoryIO.readFromUserDefaults(level: level)
        return ((highScores.count != 10) ? true : (highScores[highScores.count - 1].timeElapsed>timeElapsed))
    }
    
    // MARK: - Navigation
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}



// MARK: - PROTOCOL FOR TABLE-VIEW
extension HighScoresViewController :UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScoresToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.HighScores_TBLV_list.dequeueReusableCell(withIdentifier: "highScoreCell", for: indexPath) as? HighScoresTableViewCell
        
        cell?.highScores_LBL_rank.text = "\(indexPath.row + 1))"
        
        cell?.highScores_LBL_name.text = self.highScoresToShow[indexPath.row].playerName
        
        let seconds = String(format: "%02d", (self.highScoresToShow[indexPath.row].timeElapsed%60))
        let minutes = String(format: "%02d", self.highScoresToShow[indexPath.row].timeElapsed/60)
        cell?.highScores_LBL_elapsedTime.text = "\(minutes):\(seconds)"
        
        cell?.highScores_LBL_location.text = self.highScoresToShow[indexPath.row].gameLocation.toString
        cell?.highScores_LBL_date.text = self.highScoresToShow[indexPath.row].dateOfGame
        createMarksOnMap(latitude: self.highScoresToShow[indexPath.row].gameLocation.latitude, longitude: self.highScoresToShow[indexPath.row].gameLocation.longitude,title: self.highScoresToShow[indexPath.row].dateOfGame)
        
        if (cell == nil){
            cell = HighScoresTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "highScoreCell")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        createRegion(
            latitude: self.highScoresToShow[indexPath.row].gameLocation.latitude,
            longitude: self.highScoresToShow[indexPath.row].gameLocation.longitude)
    }
}

//MARK:- CLLocationManagerDelegate Methods
extension HighScoresViewController : CLLocationManagerDelegate  {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let mUserLocation = locations.last {
            locationManager.stopUpdatingLocation()
            newHighScore?.gameLocation = Location(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
            createRegion(
                latitude: mUserLocation.coordinate.latitude,
                longitude: mUserLocation.coordinate.longitude)
            print("Location Aquired!")
        }
        addNewHighScore(newHighScore: self.newHighScore!, level: self.level!)
        HighScores_TBLV_list.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    
    func createRegion(latitude:Double,longitude:Double){
        let mRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude),
            latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        HighScores_MAP_map.setRegion(mRegion, animated: true)
    }
    
    func checkLocationAuthorization( ) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .denied:
            GPSAlert()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            GPSAlert()
            break
        case .authorizedAlways:
            locationManager.requestLocation()
            break
        default:
            break
        }
    }
    
    func determineCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            GPSAlert()
        }
    }
    
    func GPSAlert(){
        let alert = UIAlertController(title: "Current Location Not Available", message: "Your current location cannot be determined at this time. Cannot save High Score.", preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in self.backButtonPressed(self)})
        alert.addAction(alertAction)
        present(alert,animated: true, completion: nil)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func createMarksOnMap(latitude:Double,longitude:Double ,title:String) {
        // Get user's Current Location and Drop a pin
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mkAnnotation.title = title
        HighScores_MAP_map.addAnnotation(mkAnnotation)
    }
}

