//
//  FavoritesListViewController.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

class FavoritesTableViewController: UITableViewController {
    
    var favoriteBuoys: [Buoy] = []
    
    let buoyCellIdentifier = "WeatherBuoyTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.register(UINib(nibName: "WeatherBuoyTableViewCell", bundle: nil), forCellReuseIdentifier: buoyCellIdentifier)
        self.tableView.rowHeight = 60.0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(fetchBuoyData))
        self.title = "Favorites"
        
        fetchBuoyData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.favoriteBuoys = BuoyService.getFavoriteBuoys()
        self.tableView.reloadData()
    }

    @objc func fetchBuoyData() {
        BuoyService.getBuoyData(fromLocation: hardCodedLocation) { [weak self] (buoys: [Buoy]?, error: Error?) in
            guard error == nil else { return }
            
            self?.favoriteBuoys = BuoyService.getFavoriteBuoys()
            DispatchQueue.main.sync {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteBuoys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherBuoyTableViewCell = tableView.dequeueReusableCell(withIdentifier: buoyCellIdentifier) as! WeatherBuoyTableViewCell
        
        cell.configure(withBuoy: favoriteBuoys[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let detailViewController = BuoyDetailViewController.instantiate(withBuoy: favoriteBuoys[indexPath.row])
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

}
