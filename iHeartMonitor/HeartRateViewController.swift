//
//  HeartRateViewController.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/12/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//
import UIKit
import HealthKit
import Charts

class HeartRateViewController: UIViewController {
    
    
    @IBOutlet weak var HeartRateLineChartView: LineChartView!
    //create a toggle for day, week,month toggle
    @IBOutlet weak var LineChartView2: LineChartView!
    
    var beats: [Double] = []
    let cellReuseIdentifier = "heartrate"
    var dataEntries: [ChartDataEntry] = []
    let heartRateUnit = HKUnit(from: "count/min")
    public let healthStore = HKHealthStore()
    @IBAction func chartToggle(_ sender: UISegmentedControl) {
     //   let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        switch sender.selectedSegmentIndex {
        case 0:
            print("daily")
            observerWeeklyHeartRateSamples()
           // HeartRateLineChartView.isHidden=false
          //  LineChartView2.isHidden=true
            
        case 1:
            print("weekly")
             self.beats = []
            observerMonthlyHeartRateSamples()
         //   HeartRateLineChartView.isHidden=true
          //  LineChartView2.isHidden=false
        case 2:
             self.beats = []
            print("monthly")
     
        default:
            print("default")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let auth: Bool = self.authorizeHealthKitinApp()
        if auth == true {
            observerHeartRateSamples()
           // updateChartData()
        } else {
            beats.removeAll()
            print("Unable to authorize HealthKit")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func authorizeHealthKitinApp() -> Bool
    {
        
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.workoutType(),
            ]
        
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            print("Error Occured!!!")
            return false
        }
        
        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead){ (success, error) -> Void in
            print("Was healthkit authorization successful? \(success)")
        }
        
        return true
    }
    
    func observerHeartRateSamples() {
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
        
        let observerQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.fetchLatestHeartRateSample { (sample) in
                guard let sample = sample else {
                    print("============================")
                    return
                }
                //                DispatchQueue.main.async {
                let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                print("Heart Rate : \(heartRate)")
                self.beats.append(heartRate)
                print("\(self.beats)")
                //                }
            }
       /*   self.fetchWeeklyHeartRate { (sample) in
                guard let sample = sample else {
                    print("============================")
                    return
                }
                //                DispatchQueue.main.async {
                let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                print("Heart Rate week: \(heartRate)")
                self.beats.append(heartRate)
                print("\(self.beats)")
                //                }
            } */
        
        } //end observer query
        healthStore.execute(observerQuery)
    }
    func observerWeeklyHeartRateSamples() {
        print("inside weekly heart rate samples")
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
        
        let observerQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
       /*    self.fetchLatestHeartRateSample { (sample) in
                guard let sample = sample else {
                    print("============================")
                    return
                }
                //                DispatchQueue.main.async {
                let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                print("Heart Rate Yamini: \(heartRate)")
                self.beats.append(heartRate)
                print("\(self.beats)")
                //                }
            } */
            self.fetchWeeklyHeartRate { (sample) in
                guard let sample = sample else {
                    print("============================")
                    return
                }
                //                DispatchQueue.main.async {
                let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                print("Heart Rate week: \(heartRate)")
                self.beats.append(heartRate)
                print("\(self.beats)")
                //                }
            }
            
        } //end observer query
        healthStore.execute(observerQuery)
    }
    
    func observerMonthlyHeartRateSamples() {
        print("inside weekly heart rate samples")
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
        
        let observerQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            /*    self.fetchLatestHeartRateSample { (sample) in
             guard let sample = sample else {
             print("============================")
             return
             }
             //                DispatchQueue.main.async {
             let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
             print("Heart Rate Yamini: \(heartRate)")
             self.beats.append(heartRate)
             print("\(self.beats)")
             //                }
             } */
            self.fetchMonthlyHeartRate { (sample) in
                guard let sample = sample else {
                    print("============================")
                    return
                }
                //                DispatchQueue.main.async {
                let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                print("Heart Rate month: \(heartRate)")
                self.beats.append(heartRate)
                print("\(self.beats)")
                //                }
            }
            
        } //end observer query
        healthStore.execute(observerQuery)
    }
    func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
        }
        healthStore.execute(query)
    }
    
    func updateChartData(){
        //        this is the Array that will eventually display on th graph
        //        let hearRateRange = [60, 70, 80, 90, 100]
        //        let hourly = ["6.00 PM", "6.05 PM", "6.10 PM", "6.15 PM", "6.20 PM", "6.25 PM", "6.30 PM", "6.35 PM", "6.40 PM", "6.45 PM", "6.50 PM", "6.55 PM", "7.00 PM"]
        //        let day = ["12 AM"," 1 AM","2 AM","3 AM","4 AM","5 AM","6 AM", "7 AM","8 AM","9 AM","10 AM", "11 AM", "12 PM"," 1 PM","2 PM","3 PM","4 PM","5 PM","6 PM", "7 PM","8 PM","9 PM","10 PM", "11 PM" ]
        //        let week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let month = ["Week 1", "Week 2", "Week 3", "Week 4"]
        //        let year = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "July","Aug", "Sep", "Nov", "Dec"]
        
        //   here is the for loop to calcualte the X axis and Y axis
        
        for i in 0..<month.count{
            print(self.beats)
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(i))
            self.dataEntries.append(dataEntry)
        }
        
        //        Here we convert linechartEntry to a LineChartDataSet
        let line1 = LineChartDataSet(values: self.dataEntries, label: "Number")
           let line2 = LineChartDataSet(values: self.dataEntries, label: "Integer")
        //  Sets the colour to blue
        line1.colors = [NSUIColor.blue]
         line2.colors = [NSUIColor.red]
        
        //   This is the object that will be added to the chart
        let data = LineChartData(dataSet: line1)
        _ = LineChartData(dataSet: line2)
        //        finally = its adds the chart data to the chart and causes an update
        HeartRateLineChartView.data = data
        
        //        Here we set the tile for the graph
        HeartRateLineChartView.chartDescription?.text = "HeartRate Chart"
    }
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //Function to find average heart rate
    func getAVGHeartRate(completion: @escaping (_ array: [Double]) -> Void) {
        
        let typeHeart = HKQuantityType.quantityType(forIdentifier: .heartRate)
        let startDate = Date() - 7 * 24 * 60 * 60 // start date is a week
        let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: HKQueryOptions.strictEndDate)
        
        let squery = HKStatisticsQuery(quantityType: typeHeart!, quantitySamplePredicate: predicate, options: .discreteAverage, completionHandler: {(query: HKStatisticsQuery,result: HKStatistics?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                let quantity: HKQuantity? = result?.averageQuantity()
                var _: Double? = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                //print("got")
            })
        })
        healthStore.execute(squery)
    }
    
    
    
    //step function
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            guard let result = result else {
                print("Failed to fetch steps rate")
                completion(resultCount)
                return
            }
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
                completion(resultCount)
            }
        }
        healthStore.execute(query)
        //print("sucess")
    }
    func fetchWeeklyHeartRate(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void)  {
        print("Fetching weekly heart rate data")
        
        let quantityType : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        //Fetch the last 7 days of HEARTRATE.
        
        let startDate = Date.init(timeIntervalSinceNow: -7*24*60*60)
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: quantityType.first!,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                            if let error = error {
                                                print("Error: \(error.localizedDescription)")
                                                return
                                            }
                                            
                                            completionHandler(results?[0] as? HKQuantitySample)
                                            print("bfr start")
                                          for iter in 0..<results!.count
                                                
                                            {
                                                guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
                                                print("[\(iter)]")
                                                print("Heart Rate: \(currData.quantity.doubleValue(for: self.heartRateUnit))")
                                                print("quantityType: \(currData.quantityType)")
                                                print("Start Date: \(currData.startDate)")
                                                print("End Date: \(currData.endDate)")
                                            //    print("Metadata: \(currData.metadata)")
                                               
                                                print("Source: \(currData.sourceRevision)")
                                               // print("Device: \(currData.device)")
                                                print("---------------------------------\n")
                                                //currData.startDate.timeIntervalSince1970
                                                 DispatchQueue.main.async {
                                                  let dataEntry = ChartDataEntry(x:Double(iter) , y:currData.quantity.doubleValue(for: self.heartRateUnit))
                                                 self.dataEntries.append(dataEntry)
                                                }
                                            }
                                            //        Here we convert linechartEntry to a LineChartDataSet
                                            let line1 = LineChartDataSet(values: self.dataEntries, label: "Time vs HeartRate View")
                                        
                                            //  Sets the colour to blue
                                            line1.colors = [NSUIColor.blue]
                                           
                                            
                                            //   This is the object that will be added to the chart
                                            let data = LineChartData(dataSet: line1)
                                         
                                            //        finally = its adds the chart data to the chart and causes an update
                                            self.HeartRateLineChartView.data = data
                                            
                                            //        Here we set the tile for the graph
                                            self.HeartRateLineChartView.chartDescription?.text = "HeartRate Chart"
                                          /*  for i in results as! [HKQuantitySample]
                                            {
                                                print("Heart Rate ashwin: \(i)")
                                            } */
        }
        
        
        self.healthStore.execute(sampleQuery)
    }
    func fetchMonthlyHeartRate(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void)  {
        print("Fetching monthly heart rate data")
        
        let quantityType : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        //Fetch the last 30 days of HEARTRATE.
        
        let startDate = Date.init(timeIntervalSinceNow: -30*24*60*60)
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: quantityType.first!,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                            if let error = error {
                                                print("Error: \(error.localizedDescription)")
                                                return
                                            }
                                            
                                            completionHandler(results?[0] as? HKQuantitySample)
                                            print("bfr start")
                                            for iter in 0..<results!.count
                                                
                                            {
                                                guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
                                                print("[\(iter)]")
                                                print("Heart Rate: \(currData.quantity.doubleValue(for: self.heartRateUnit))")
                                                print("quantityType: \(currData.quantityType)")
                                                print("Start Date: \(currData.startDate)")
                                                print("End Date: \(currData.endDate)")
                                                //    print("Metadata: \(currData.metadata)")
                                                
                                                print("Source: \(currData.sourceRevision)")
                                                // print("Device: \(currData.device)")
                                                print("---------------------------------\n")
                                                //currData.startDate.timeIntervalSince1970
                                                DispatchQueue.main.async {
                                                    let dataEntry = ChartDataEntry(x:Double(iter) , y:currData.quantity.doubleValue(for: self.heartRateUnit))
                                                    self.dataEntries.append(dataEntry)
                                                }
                                            }
                                            //        Here we convert linechartEntry to a LineChartDataSet
                                            let line1 = LineChartDataSet(values: self.dataEntries, label: " Monthly HeartRate View")
                                            
                                            //  Sets the colour to blue
                                            line1.colors = [NSUIColor.red]
                                            
                                            
                                            //   This is the object that will be added to the chart
                                            let data = LineChartData(dataSet: line1)
                                            
                                            //        finally = its adds the chart data to the chart and causes an update
                                            self.LineChartView2.data = data
                                            
                                            //        Here we set the tile for the graph
                                            self.LineChartView2.chartDescription?.text = "HELLO Chart"
                                            /*  for i in results as! [HKQuantitySample]
                                             {
                                             print("Heart Rate : \(i)")
                                             } */
        }
        
        
        self.healthStore.execute(sampleQuery)
    }
    
    func fetchDailyHeartRate(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void)  {
        print("Fetching daily heart rate data")
        
        let quantityType : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        //Fetch the last 30 days of HEARTRATE.
        
        let startDate = Date.init(timeIntervalSinceNow: -1*24*60*60)
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate,
                                                    options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: quantityType.first!,
                                        predicate: predicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                            if let error = error {
                                                print("Error: \(error.localizedDescription)")
                                                return
                                            }
                                            
                                            completionHandler(results?[0] as? HKQuantitySample)
                                            print("bfr start")
                                            for iter in 0..<results!.count
                                                
                                            {
                                                guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
                                                print("[\(iter)]")
                                                print("Heart Rate: \(currData.quantity.doubleValue(for: self.heartRateUnit))")
                                                print("quantityType: \(currData.quantityType)")
                                                print("Start Date: \(currData.startDate)")
                                                print("End Date: \(currData.endDate)")
                                                //    print("Metadata: \(currData.metadata)")
                                                
                                                print("Source: \(currData.sourceRevision)")
                                                // print("Device: \(currData.device)")
                                                print("---------------------------------\n")
                                                //currData.startDate.timeIntervalSince1970
                                                DispatchQueue.main.async {
                                                    let dataEntry = ChartDataEntry(x:Double(iter) , y:currData.quantity.doubleValue(for: self.heartRateUnit))
                                                    self.dataEntries.append(dataEntry)
                                                }
                                            }
                                            //        Here we convert linechartEntry to a LineChartDataSet
                                            let line1 = LineChartDataSet(values: self.dataEntries, label: " daily HeartRate View")
                                            
                                            //  Sets the colour to blue
                                            line1.colors = [NSUIColor.red]
                                            
                                            
                                            //   This is the object that will be added to the chart
                                            let data = LineChartData(dataSet: line1)
                                            
                                            //        finally = its adds the chart data to the chart and causes an update
                                            self.LineChartView2.data = data
                                            
                                            //        Here we set the tile for the graph
                                            self.LineChartView2.chartDescription?.text = "HELLO Chart"
                                            /*  for i in results as! [HKQuantitySample]
                                             {
                                             print("Heart Rate : \(i)")
                                             } */
        }
        
        
        self.healthStore.execute(sampleQuery)
    }
    
    
}
