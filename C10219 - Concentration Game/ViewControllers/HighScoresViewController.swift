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
    
    var newHighScore:HighScore?
    var level:String?
    
    var locationManager:CLLocationManager!
    var location:Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //clearUserDefaults()
        navigationController?.setNavigationBarHidden(true,animated: false)
        HighScores_SEGCTRL_level.selectedSegmentIndex = segmentedInitialIndex
        HighScores_TBLV_list.delegate = self
        HighScores_TBLV_list.dataSource = self
        LevelPicked(HighScores_SEGCTRL_level)
        if (newHighScore != nil && level != nil){
            determineCurrentLocation()
        }
        if !highScoresToShow.isEmpty {
        HighScores_TBLV_list.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.top)
        let location = CLLocationCoordinate2D(latitude: highScoresToShow[0].gameLocation.latitude , longitude:highScoresToShow[0].gameLocation.longitude  )
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            HighScores_MAP_map.setRegion(region, animated: true)
            
        }
    }
        
    //MARK: - SegmentedControl Picker
    @IBAction func LevelPicked(_ sender: UISegmentedControl) {
        highScoresToShow = readFromUserDefaults(level: sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        print("HighScores for level \(sender.titleForSegment(at: sender.selectedSegmentIndex)!) Loaded")
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
        highScores.append(newHighScore)
        highScores.sort(by: {$0.timeElapsed < $1.timeElapsed})
        writeToUserDefaults(highScores: highScores, level: level)
        self.highScoresToShow = highScores
        HighScores_TBLV_list.reloadData()
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
            locationManager.stopUpdatingLocation()
            newHighScore?.gameLocation = Location(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
            let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
            let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

            HighScores_MAP_map.setRegion(mRegion, animated: true)
            print("Location Aquired!")
        }
        addNewHighScore(newHighScore: self.newHighScore!, level: self.level!)
        HighScores_TBLV_list.reloadData()
    }
    
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    
    //MARK:- Intance Methods
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    func createMarksOnMap(latitude:Double,longitude:Double ,title:String) {
        // Get user's Current Location and Drop a pin
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mkAnnotation.title = title
        HighScores_MAP_map.addAnnotation(mkAnnotation)
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
        
        cell?.highScores_LBL_location.text = self.highScoresToShow[indexPath.row].gameLocation.toString
        cell?.highScores_LBL_date.text = self.highScoresToShow[indexPath.row].dateOfGame
        
        createMarksOnMap(latitude: self.highScoresToShow[indexPath.row].gameLocation.latitude, longitude: self.highScoresToShow[indexPath.row].gameLocation.longitude,title: self.highScoresToShow[indexPath.row].dateOfGame)
        
        if(cell == nil){
            cell = HighScoresTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "highScoreCell")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = CLLocationCoordinate2D(latitude: highScoresToShow[indexPath.row].gameLocation.latitude , longitude:highScoresToShow[indexPath.row].gameLocation.longitude  )
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        HighScores_MAP_map.setRegion(region, animated: true)
    }
    
    // MARK: - Clean User Defaults
    func clearUserDefaults(){
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
    }
    
    //MARK: - HighScore Check
    func checkForHighScoreInLevel(timeElapsed:Int,level :String) -> Bool {
        let highScores = readFromUserDefaults(level: level)
      
        return ((highScores.count != 10) ? true : (highScores[highScores.count - 1].timeElapsed>timeElapsed))
    }
}

