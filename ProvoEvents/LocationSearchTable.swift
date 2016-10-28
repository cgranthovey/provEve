//
//  LocationSearchTable.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/28/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController{
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil

    var handleMapSearchDelegate: HandleMapSearch? = nil
}

extension LocationSearchTable : UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.getAddressInfo()
        return cell
    }
}

extension LocationSearchTable {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        let eventAddress = selectedItem.getAddressInfo()
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem, addressString: eventAddress, fromTap: false)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
