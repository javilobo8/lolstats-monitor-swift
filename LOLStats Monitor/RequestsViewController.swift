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

class RequestsViewController: UIViewController {
    
    let urlPath = "http://lobobot.com:1337/requests"
    let auth = "211a6e6a1fc289045b9cf64839beefce"
    
    @IBOutlet weak var lineChartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.pinchZoomEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = false
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.drawBottomYLabelEntryEnabled = false
        lineChartView.leftAxis.drawTopYLabelEntryEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        lineChartView.legend.enabled = false
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
            print("\(json)")
            var arrayData = Array<Double>()
            for (_, number):(String, JSON) in json { arrayData.append(number.double!) }

            DispatchQueue.main.async{
                self.printChart(data: arrayData)
            }
        }
        task.resume()
    }
    
    func printChart(data: Array<Double>) {
        let yse1 = data.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let data = LineChartData()
        
        let ds1 = LineChartDataSet(values: yse1, label: "Hello")
        ds1.colors = [UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)]
        ds1.drawValuesEnabled = false
        ds1.circleRadius = 0
        data.addDataSet(ds1)
        
        self.lineChartView.data = data
        self.lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        self.view.reloadInputViews()
    }
}
