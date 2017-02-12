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

let blueColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)

class UsersViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let auth = "211a6e6a1fc289045b9cf64839beefce"
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var selectedDate: String!
    var pickOptions: [String]!
    
    var pickDays: [String]!
    var pickMonths: [String]!
    var pickYears: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickDays = self.generateDays()
        pickMonths = self.generateMonths()
        pickYears = self.generateYears()
        
        pickOptions = pickDays

        pickerView.delegate = self
        pickerView.selectRow(pickOptions.count - 1, inComponent: 0, animated: false)
        
        let initialDate = pickOptions[pickOptions.count - 1]
        selectedDate = initialDate
        
        barChartView.pinchZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
//        barChartView.chartDescription?.enabled = false
        barChartView.dragEnabled = false
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.drawBottomYLabelEntryEnabled = false
        barChartView.leftAxis.drawTopYLabelEntryEnabled = false
        barChartView.leftAxis.enabled = true
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartView.legend.enabled = false
        barChartView.fitBars = true
        
        let numberF = NumberFormatter()
        numberF.minimumFractionDigits = 0
        numberF.maximumFractionDigits = 1
        numberF.negativeSuffix = " $";
        numberF.positiveSuffix = " $";
        
//        barChartView.leftAxis.valueFormatter = IAxisValueFormatter(numberF)

        self.requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func generateDays() -> [String] {
        let calendar = Calendar.current
        var startDate = DateComponents()
        startDate.year = 2016
        startDate.month = 7
        startDate.day = 1
        var date = calendar.date(from: startDate)!
        let endDate = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        var dates:[String] = []
        while date <= endDate {
            dates.append(fmt.string(from: date))
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return dates
    }
    
    func generateMonths() -> [String] {
        let calendar = Calendar.current
        var startDate = DateComponents()
        startDate.year = 2016
        startDate.month = 7
        startDate.day = 1
        var date = calendar.date(from: startDate)!
        let endDate = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM"
        var dates:[String] = []
        while date <= endDate {
            dates.append(fmt.string(from: date))
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        return dates
    }
    
    func generateYears() -> [String] {
        return ["2016", "2017"]
    }
    
    func replaceSegments(segments: Array<String>) {
//        for segment in segments {
//            self.insertSegmentWithTitle(segment, atIndex: self.numberOfSegments, animated: false)
//        }
    }

    @IBAction func changeDateInterval(_ sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        switch selected {
        case 0:
            self.pickOptions = pickDays
            break
        case 1:
            self.pickOptions = pickMonths
            break
        case 2:
            self.pickOptions = pickYears
            break
        default:
            self.pickOptions = pickDays
            break
        }
        self.pickerView.reloadAllComponents()
        self.pickerView.selectRow(pickOptions.count - 1, inComponent: 0, animated: true)
        selectedDate = pickOptions.last
        self.requestData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDate = pickOptions[row]
        self.requestData()
    }
    
    func requestData() {
        var urlPath = "http://lobobot.com:1337/users"

        if self.selectedDate != nil {
            urlPath = urlPath + "?date=" + self.selectedDate
//            print("\(urlPath)")
        }

        guard let endpoint = URL(string: urlPath) else {
            print("Error creating endpoint")
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.setValue(auth, forHTTPHeaderField: "auth")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {(data, response, err) in
            let json = JSON(data: data!)

            let chartData = json.array
            var arrayData = Array<Double>()
            for (_, number):(String, JSON) in JSON(chartData!) { arrayData.append(number.double!) }
            
            DispatchQueue.main.async{
                self.printChart(data: arrayData)
            }
        }
        task.resume()
    }
    
    func printChart(data: Array<Double>) {
        let yse1 = data.enumerated().map { x, y in return BarChartDataEntry(x: Double(x), y: y) }
        let data = BarChartData()
        
        let ds1 = BarChartDataSet(values: yse1, label: "Hello")
        barChartView.chartDescription?.text = "Max: \(Int(ds1.yMax))"
        ds1.colors = [blueColor]
        ds1.drawValuesEnabled = false
        data.addDataSet(ds1)
        
        self.barChartView.data = data
        self.barChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        self.view.reloadInputViews()
    }
}
