//
//  HighScoresViewController.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 31/05/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit

class HighScoresViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true,animated: false)

        // Do any additional setup after loading the view.
    }
        
    // MARK: - Navigation
     @IBAction func backButtonPressed(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
     }

}
