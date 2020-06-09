//
//  CardCollectionViewCell.swift
//  C10219 - Concentration Game
//
//  Created by Tom Cohen on 28/04/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Members
    @IBOutlet weak var card_IMG_front:UIImageView!
    @IBOutlet weak var card_IMG_back:UIImageView!
    
    var card:Card?
    
    //MARK: - setCard
    func setCard (_ card:Card){
        
        self.card = card
        
        if card.isMatched == true {
            card_IMG_back.alpha = 0
            card_IMG_front.alpha = 0
            return
        }
        else{
            card_IMG_back.alpha = 1
            card_IMG_front.alpha = 1
        }
        
        card_IMG_front.image = UIImage(named: card.imageName)
        
        //reshow card
        if card.isShown == true{
            UIView.transition(from: card_IMG_back, to: card_IMG_front, duration: 0, options: [.transitionFlipFromLeft,.showHideTransitionViews], completion: nil)
        }
        else{
            UIView.transition(from: card_IMG_front, to: card_IMG_back, duration: 0, options: [.transitionFlipFromLeft,.showHideTransitionViews], completion: nil)
        }
    }
    
    //MARK: - Card Actions
    func flip() {
        UIView.transition(from: card_IMG_back, to: card_IMG_front, duration: 0.2, options: [.transitionFlipFromLeft,.showHideTransitionViews], completion: nil)
    }
    
    func flipBack() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            UIView.transition(from: self.card_IMG_front, to: self.card_IMG_back , duration: 0.2, options: [.transitionFlipFromRight,.showHideTransitionViews], completion: nil)
        }
    }
    
    func remove(){
        
        card_IMG_back.alpha=0
        
        UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseOut, animations: {
            self.card_IMG_front.alpha=0
        }, completion: nil)
    }
}
