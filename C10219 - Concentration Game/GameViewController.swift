//
//  GameViewController.swift
//  C10219 - Concentration Game
//
//  Created by user167774 on 16/04/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit

class GameViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var main_CV_cards: UICollectionView!
    
    var cards = [Card]()
    var model = CardModel()
    
    @IBOutlet weak var main_LBL_timer: UILabel!
    var firstCardFlipped:IndexPath?
    
    
    var timer:Timer?
    var milis:Float = 35*1000
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get randomized new deck of cards
        //cards = model.getDeck()
        resetGame()
//        main_CV_cards.delegate = self
//        main_CV_cards.dataSource = self
        
        //timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        //RunLoop.main.add(timer!, forMode: .common)
        
    }
    //MARK: UICollectionView Related Protocols:
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = main_CV_cards.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        let card = cards[indexPath.row]
        
        cell.setCard(card)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if milis <= 0{
            return}
        let cell = main_CV_cards.cellForItem(at: indexPath)  as! CardCollectionViewCell
        let card = cards[indexPath.row]
        if card.isShown == false && card.isMatched == false {
            cell.flip()
            card.isShown = true
            
            if firstCardFlipped == nil{
                firstCardFlipped = indexPath
            }
            else{
                checkMatch(indexPath)
            }
        }
        
    }
    //MARK: Game Logic:
    func checkMatch (_ secondCardFlipped:IndexPath)
    {
        let cell1 = main_CV_cards.cellForItem(at: firstCardFlipped! )as? CardCollectionViewCell
        let cell2 = main_CV_cards.cellForItem(at: secondCardFlipped )as? CardCollectionViewCell
        
        let card1 = cards[firstCardFlipped!.row]
        let card2 = cards[secondCardFlipped.row]
        
        if card1.imageName == card2.imageName {
            card1.isMatched=true
            card2.isMatched=true
            
            cell1?.remove()
            cell2?.remove()
            
            isGameEnded()
        } else{
            card1.isShown=false
            card2.isShown=false
            
            cell1?.flipBack()
            cell2?.flipBack()
        }
        
        if cell1 == nil{
            main_CV_cards.reloadItems(at: [firstCardFlipped!])
        }
        
        firstCardFlipped = nil
    }
    
    func isGameEnded(){
        var isWon = true
        
        for card in cards {
            if card.isMatched == false
            {
                isWon=false
                break
            }
        }
        
        var title = ""
        var message = ""
        
        if isWon{
            timer?.invalidate()
            title = "Congratulations!"
            message = "You've Won!"
            
        }else{
            if milis > 0{
                return
            }
            title = "Game Over!"
            message = "You've Lost!"
        }
        
        showAlert(title, message)
        
    }
    
    func showAlert(_ title:String, _ message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //let alertAction = UIAlertAction(title: "Ok", style: .default, handler: )
        let alertAction = UIAlertAction(title: "Start Again!", style: .default, handler: {(alert: UIAlertAction!) in self.resetGame()})
        alert.addAction(alertAction)
        present(alert,animated: true, completion: nil)
    }
    
    func resetGame()
    {
        cards = model.getDeck()
        milis = 35*1000
        main_CV_cards.delegate = self
        main_CV_cards.dataSource = self
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        firstCardFlipped = nil
        main_CV_cards.reloadData()
    }
    
    //MARK: Timer:
    @objc func timerElapsed(){
        milis -= 1
        
        let seconds = String(format: "%.2f", milis/1000)
        main_LBL_timer.text = "\(seconds)"
        
        if milis <= 0{
            timer?.invalidate()
            
            isGameEnded()
        }
    }
    
    
}
