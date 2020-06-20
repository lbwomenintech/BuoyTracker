//
//  BuoyViewController.swift
//  BuoyTracker
//
//  Created by Owen Pierce on 6/20/20.
//  Copyright © 2020 Curious Robot Labs. All rights reserved.
//

import UIKit
import MapKit

class BuoyTableViewController: UITableViewController, BuoyRequester {
    
    var buoyList: [Buoy] = []
    
    let buoyCellIdentifier = "weatherBuoyCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Buoy Stations"
        
        self.tableView.register(UINib(nibName: "WeatherBuoyTableViewCell", bundle: nil), forCellReuseIdentifier: buoyCellIdentifier)
        self.tableView.rowHeight = 60.0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
        
        if BuoyService.shared.buoyList.count == 0 {
            fetchBuoyData(fromLocation: hardCodedLocation)
        } else {
            buoyList = BuoyService.shared.buoyList
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshData() {
        fetchBuoyData(fromLocation: hardCodedLocation)
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buoyList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherBuoyTableViewCell = tableView.dequeueReusableCell(withIdentifier: buoyCellIdentifier) as! WeatherBuoyTableViewCell
        
        cell.configure(withBuoy: buoyList[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let detailViewController = BuoyDetailViewController.instantiate(withBuoy: buoyList[indexPath.row])
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

}

