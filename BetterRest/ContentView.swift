//
//  ContentView.swift
//  BetterRest
//
//  Created by Nilesh Rathod on 21/04/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State  private var alertTitle = ""
    @State  private var alertTMessage = ""
    @State  private var showAlert = false
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        
        NavigationView{
            Form {
                Section{
                    DatePicker("Please enter atime", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    
                    
                } header: {
                    Text("When do you want to wakeup?")
                        .font(.headline  )
                }
                
                Section{
                    Stepper(" \(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                }
                
                Section{
                    
                    Picker(coffeeAmount == 1 ?"1 cup" :"\(coffeeAmount) cups", selection: $coffeeAmount){
                        ForEach((1...20), id: \.self){
                            Text("\($0)")
                        }
                    }.pickerStyle(.navigationLink)
                } header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
            }
            .onChange(of: sleepAmount, perform: { _ in
                calculateBedTime()
            })
            .navigationTitle("BetterRest")
           
            .alert(alertTitle, isPresented: $showAlert){
                Button("OK"){
                    
                }
            } message: {
                Text(alertTMessage)
            }
        }
    }
    
    func calculateBedTime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your idle bedtime is..."
            alertTMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch{
            alertTitle = "Error"
            alertTMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
