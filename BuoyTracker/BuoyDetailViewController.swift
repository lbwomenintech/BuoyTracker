//
//  BuoyDetailViewController.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit

class BuoyDetailViewController: UIViewController {

    var selectedBuoy: Buoy!
    
    @IBOutlet var buoyNameLabel: UILabel!
    @IBOutlet var buoyDescriptionTextView: UITextView!
    @IBOutlet var favoriteButton: UIButton!
    
    static func instantiate(withBuoy buoy: Buoy) -> BuoyDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "BuoyDetailViewController") as! BuoyDetailViewController
        detailViewController.selectedBuoy = buoy
        
        return detailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buoyNameLabel.text = selectedBuoy.name
        buoyNameLabel.lineBreakMode = .byWordWrapping
        buoyNameLabel.numberOfLines = 0
        
        favoriteButton.layer.cornerRadius = 6.0
        favoriteButton.clipsToBounds = true
        
        // present data with HTML formatting preserved
        let htmlData = selectedBuoy.descriptionString?.data(using: String.Encoding(rawValue: String.Encoding.unicode.rawValue))
        do {
            try buoyDescriptionTextView.attributedText =
                NSAttributedString(data: htmlData!,
                                   options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                   documentAttributes: nil)
        } catch {
            print("Could not build attributed string")
        }
        
        // Assuming that the first component of the station name is a quick callsign
        // Note: this is still safe for buoys with a name of SHIP
        self.title = selectedBuoy.name?.components(separatedBy: "-").first
        
        if let stationId = self.selectedBuoy.stationId,
            BuoyService.getFavoriteBuoyIds().contains(stationId) {
            self.selectedBuoy.isFavorite = true
        }
        
        updateFavoriteButtonTitle()
    }
    
    func updateFavoriteButtonTitle() {
        if selectedBuoy.isFavorite {
            self.favoriteButton.setTitle("REMOVE FAVORITE", for: .normal)
        } else {
            self.favoriteButton.setTitle("ADD FAVORITE", for: .normal)
        }
    }

    @IBAction func favoriteButtonPressed() {
        
        if selectedBuoy.isFavorite {
            BuoyService.removeFavorite(buoy: selectedBuoy)
        } else {
            BuoyService.addFavorite(buoy: selectedBuoy)
        }
        
        self.selectedBuoy.isFavorite = !self.selectedBuoy.isFavorite
        updateFavoriteButtonTitle()
    }
}
