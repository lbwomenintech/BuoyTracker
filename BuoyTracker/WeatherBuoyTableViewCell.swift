//
//  WeatherBuoyTableViewCell.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit

class WeatherBuoyTableViewCell: UITableViewCell {

    @IBOutlet var buoyNameLabel: UILabel!

    func configure(withBuoy buoy: Buoy) {
        buoyNameLabel.text = buoy.name
    }

}

