//
//  UsersViewController.swift
//  LOLStats Monitor
//
//  Created by Lobo on 11/02/2017.
//  Copyright © 2017 Lobo. All rights reserved.
//

import UIKit
import Charts
import Foundation
import SwiftyJSON

class UsersViewController: UIViewController {
    
    let urlPath = "http://lobobot.com:1337/users"
    let auth = "211a6e6a1fc289045b9cf64839beefce"

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var usersTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        barChartView.delegate = self
        barChartView.pinchZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.chartDescription?.enabled = false
        barChartView.dragEnabled = false
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.drawBottomYLabelEntryEnabled = false
        barChartView.leftAxis.drawTopYLabelEntryEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartView.legend.enabled = false
        barChartView.fitBars = true
        self.requestData()
    }

    @IBAction func refreshActionButton(_ sender: Any) {
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestData() {
        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.setValue(auth, forHTTPHeaderField: "auth")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {(data, response, err) in
            let json = JSON(data: data!)

            let totalUsers = json["total"].int32

            let chartData = json["data"].array
            var arrayData = Array<Double>()
            for (_, number):(String, JSON) in JSON(chartData!) { arrayData.append(number.double!) }
            
            let newUsers = json["list"].array
            var arrayUsers = Array<String>()
            for (_, user):(String, JSON) in JSON(newUsers!) { arrayUsers.append(user.string!) }
            
            DispatchQueue.main.async{
                self.totalLabel.text = "Total users \(totalUsers!)"
                self.printChart(data: arrayData)
                self.printList(data: arrayUsers)
            }
        }
        task.resume()
    }
    
    func printList(data: Array<String>) {
        print("\(data)")
    }
    
    func printChart(data: Array<Double>) {
        let yse1 = data.enumerated().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
        let data = BarChartData()
        
        let ds1 = BarChartDataSet(values: yse1, label: "Hello")
        ds1.colors = [UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)]
        ds1.drawValuesEnabled = false
        data.addDataSet(ds1)
        
        self.barChartView.data = data
        self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.view.reloadInputViews()
    }
}
