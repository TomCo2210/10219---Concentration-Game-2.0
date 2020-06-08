//
//  MainViewController.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 31/05/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var imagePrefix = "casino"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true,animated: false)
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    @IBAction func LevelClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "LevelClicked", sender: sender)
    }
    
    @IBAction func HighScoresClicked(_ sender: Any) {
        performSegue(withIdentifier: "HighScoresClicked", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "HighScoresClicked") {
            _ = segue.destination as! HighScoresViewController
        }
        else {
            let vc = segue.destination as! GameViewController
            let senderBtn = sender as! UIButton
            vc.cardsTheme = self.imagePrefix
            vc.level = (senderBtn.titleLabel?.text)!
            switch (vc.level)
            {
            case "Easy":
                vc.numberOfPairs = 8
                vc.index = 0
                break
            case "Medium":
                vc.numberOfPairs = 10
                vc.index = 1
                break
            case "Hard":
                vc.numberOfPairs = 15
                vc.index = 2
                break
            default:
                vc.numberOfPairs = 8
                vc.index = 0
            }
        }
    }
    
    //MARK: Theme Picker segmented control:
    @IBAction func ThemePicked(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            imagePrefix = "casino"
            break
        case 1:
            imagePrefix = "kids"
            break
        case 2:
            imagePrefix = "sm"
            break
        case 3:
            imagePrefix = "animal"
            break
        default:
            imagePrefix = "casino"
            
        }
    }
}

