//
//  GameViewController.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 16/04/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //Deck Collection view
    @IBOutlet weak var main_CV_cards: UICollectionView!
    
    //Deck init
    var deck = [Card]()
    
    //CardModel for Deck cards
    var model = CardModel()
    
    //Match related member
    var firstCardFlipped:IndexPath?
    
    // timer related members
    @IBOutlet weak var main_LBL_timer: UILabel!
    var timer:Timer?
    var milis:Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetGame()
        
    }
    
    
    //MARK: Game Logic:
    func checkMatch (_ secondCardFlipped:IndexPath)
    {
        let cell1 = main_CV_cards.cellForItem(at: firstCardFlipped!) as? CardCollectionViewCell
        let cell2 = main_CV_cards.cellForItem(at: secondCardFlipped) as? CardCollectionViewCell
        
        let card1 = deck[firstCardFlipped!.row]
        let card2 = deck[secondCardFlipped.row]
        
        if card1.imageName == card2.imageName {
            
            //set both as matched
            card1.isMatched=true
            card2.isMatched=true
            
            //remove both from screen
            cell1?.remove()
            cell2?.remove()
            
            //check if game ended
            isGameEnded()
            
        } else{
            //flip both back
            card1.isShown=false
            card2.isShown=false
            cell1?.flipBack()
            cell2?.flipBack()
        }
        
        if cell1 == nil{
            // for cases of cell1 being recycled and needed to be reloaded
            main_CV_cards.reloadItems(at: [firstCardFlipped!])
        }
        
        firstCardFlipped = nil
    }
    
    func isGameEnded(){
        var isWon = true
        
        for card in deck {
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
            
        } else {
            if milis > 0 {
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
        let alertAction = UIAlertAction(title: "Start Again!", style: .default, handler: {(alert: UIAlertAction!) in self.resetGame()})
        alert.addAction(alertAction)
        present(alert,animated: true, completion: nil)
    }
    
    func resetGame()
    {
        deck = model.getDeck()
        milis = 90*1000
        main_CV_cards.delegate = self
        main_CV_cards.dataSource = self
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerCountDown), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        firstCardFlipped = nil
        main_CV_cards.reloadData()
        
    }
    
    //MARK: Timer:
    @objc func timerCountDown() {
        milis -= 1
        
        let seconds = String(format: "%.2f", milis/1000)
        main_LBL_timer.text = "\(seconds)"
        
        if milis <= 0 {
            timer?.invalidate()
            isGameEnded()
        }
    }
    
    // MARK: UICollectionView Related Protocols:
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deck.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Resize each card to be able to show it on low resolutions screens.
        
        // width:
        var  width = self.view.frame.size.width < self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height
        width = width - (10*10)
        width = width/4
        print(width)
        
        //height:
        var height = width / 79
        height = height * 127.5
        print(height)
        
        //return values as CGSize
        return CGSize(width: width , height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //assign Cell in CollectionView To a card in deck.
        let cell = main_CV_cards.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        let card = deck[indexPath.row]
        
        cell.setCard(card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //onClick()
        
        //if time ended, do nothing
        if milis <= 0 {
            return
        }
        
        let cell = main_CV_cards.cellForItem(at: indexPath)  as! CardCollectionViewCell
        let card = deck[indexPath.row]
        
        if card.isShown == false && card.isMatched == false {
            cell.flip()
            card.isShown = true
            
            if firstCardFlipped == nil {
                firstCardFlipped = indexPath
            } else {
                checkMatch(indexPath)
            }
        }
    }
}
