//
//  WAWeatherTilesContentView.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 06/01/2025.
//

//TODO
//colour gue
//sun position needs to be correct to hour -> sun needs 12 positions same with moon
//sync sun and moon to sunrise and moonrise

import SwiftUI
import SpriteKit

struct Item: Identifiable {
    let id = UUID()
    let location: String
    let temp: String
    let color: Color
    let time: String
    let dayType: DayType
}

struct ContentView: View {
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    @State var dayData:DayData = DayData(daysData: [])
    
    @State var sunX: CGFloat = DayData.SunPositions[0].x
    @State var sunY: CGFloat = DayData.SunPositions[0].y
    @State var sunIndex: Int = 0
    
    let weatherOffset: CGFloat = -UIScreen.main.bounds.width*1.02
    
    @State var weatherIndex = 0
    @State var weatherPos: CGFloat = UIScreen.main.bounds.width*11.73
    
    @State var clockRotation: Angle = Angle(degrees: 0)
    @State var clockIncrement: Angle = Angle(degrees: 30)
    @State var clockTime: String = "12"
    
    @State var weatherAngle: Double = 0
    @State var landscapeAngle: Double = 0
    
    @State var isLoading: Bool = false
    
    @State var presentPopUp: Bool = false
    @State var errorDescription: String = ""
    
    var body: some View {
        
        ZStack {
            
            if dayData.days.count > 0 {
                WeatherEnvironment(dayData: dayData, skyColorAngle: weatherAngle, landscapeColorAngle: landscapeAngle, weatherIndex: weatherIndex, sunX: sunX, sunY: sunY)
            }
            
            HStack {
                ForEach(dayData.days) { day in
                    
                    DayScreen(temperature: day.temp, screenColour: day.color, weatherIcon: "sun.max", weatherText: day.conditionText, screenWidth: screenWidth)
                }
            }.offset(x:weatherPos, y: 0)
                .edgesIgnoringSafeArea(.all)
            
            LocationTimeDisplay(location: dayData.location, timeString: "Today, \(dayData.currentDateTime)")
            .offset(x: -100, y:-330)
            .padding(16)

            WeatherClock(clockRotation: clockRotation, clockTime: clockTime)
                .offset(y: 390)
            
            if (isLoading){
                ProgressView()
                    .scaleEffect(3)
            }
            
            if(presentPopUp){
                Popup(isPresented: $presentPopUp, title:"Something went wrong", message:errorDescription, actionLabel:"Ok")
            }
            
        }
        .swipe( left: {
            swipeLeft()
        }, right: {
            swipeRight()
        })
        .onAppear {
            isLoading = true
            
            Task {
                do {
                    let weatherReponse = try await WeatherAPIClient.shared.getForecast(for: "London")
                    dayData = DayData(location: weatherReponse.location.name, forecastData: weatherReponse.forecast.forecastday[0].hour, dateTime: weatherReponse.location.localtime)
                    
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: weatherReponse.location.localtime)
                    
                    weatherPos = weatherPos + CGFloat(hour) * weatherOffset
                    weatherIndex = hour
                    clockTime = "\(hour)"
                    
                    isLoading = false
                    
                } catch {
                    //Convert to weather error
                    presentPopUp = true
                    if let weatherError = error as? WeatherError {
                        errorDescription = weatherError.rawValue
                    }else {
                        errorDescription = WeatherError.unableToComplete.rawValue
                    }
                    
                    isLoading = false
                }
            }
        }
    }
    
    func swipeLeft() {
        withAnimation {
            if(weatherIndex < dayData.days.count - 1){
                weatherIndex += 1
                weatherPos += weatherOffset
                clockRotation -= clockIncrement
                
                sunIndex += 1
                weatherAngle += 5
                
                if(sunIndex >= DayData.SunPositions.count){ sunIndex = 0}
            }
            
            sunX = DayData.SunPositions[sunIndex].x
            sunY = DayData.SunPositions[sunIndex].y
            
            clockTime = dayData.days[weatherIndex].time
            
            if (dayData.days[weatherIndex].dayType == DayType.day){
                landscapeAngle = 0
            }else{
                landscapeAngle = 155
            }
        }
    }
    
    func swipeRight(){
        withAnimation {
            if(weatherIndex > 0){
                weatherIndex -= 1
                weatherPos -= weatherOffset
                clockRotation += clockIncrement
                
                sunIndex -= 1
                weatherAngle -= 5
                
                if(sunIndex < 0){ sunIndex = DayData.SunPositions.count - 1}
            }
            sunX = DayData.SunPositions[sunIndex].x
            sunY = DayData.SunPositions[sunIndex].y
            
            clockTime = dayData.days[weatherIndex].time
            
            if (dayData.days[weatherIndex].dayType == DayType.day){
                landscapeAngle = 0
            }else{
                landscapeAngle = 155
            }
        }
    }
}

struct Popup: View {
    
    let containerWidth:CGFloat =  UIScreen.main.bounds.size.width - 70
    
    @Binding var isPresented: Bool
    
    let title: String
    let message: String
    let actionLabel: String
    
    var body: some View {
        
        ZStack {
        
            Rectangle()
                .fill(.black.opacity(0.9))
                .ignoresSafeArea()
                .clipShape(.rect(cornerRadius: 10))
            
            VStack(spacing: 40){
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
                
                Text(message)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding(12)
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }, label: {
                    HStack(){
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(Color.black)
                        Text(actionLabel)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                    .padding(12)
                }) .frame(width: containerWidth - 50)
                .background(Color.green)
                    .clipShape(.rect(cornerRadius: 12))
                   
            }
            .padding(16)
        } .frame(
            width: containerWidth, height: 280)
        
    }
    
}

struct LocationTimeDisplay: View {
    
    let location: String
    let timeString: String
    
    var body: some View {
        VStack(spacing: 5){
            HStack(spacing: 16) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.white)
                    .imageScale(.large)
                
                Text(location)
                    .font(.system(size: 35, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text(timeString)
                .font(.system(size: 22, weight: .light))
                .foregroundColor(.white)
                .offset(x: 10)
        }
    }
}

struct WeatherEnvironment: View {
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    let dayData:DayData
    
    let skyColorAngle: Double
    let landscapeColorAngle: Double
    let weatherIndex: Int
    let sunX: Double
    let sunY: Double
    
    var body: some View {
        Color(red: 55.8, green: 80, blue: 64.5, opacity: 1.0)
        Image("Sky").offset(y: -300)
            .hueRotation(.degrees(skyColorAngle))  //todo correct sky angle to day and night
        
        if (dayData.days[weatherIndex].dayType == DayType.day){
            Image("Sun")
                .offset(x: sunX, y: sunY)
        }else{
            Image("Stars").offset(y: -250)
            Image("Moon")
                .scaleEffect(0.6)
                .offset(x: sunX, y: sunY)
        }
        
        //Landscape
        Image("Weather Landscape")
            .hueRotation(.degrees(landscapeColorAngle))
            .offset(x: 2, y: 130)
            .scaleEffect(0.5)
        
        //Clouds
        let cloudCondition = dayData.days[weatherIndex].cloudCondition
        switch(cloudCondition){
        case _ where cloudCondition < 26:
            Image("misty-clouds")
                .opacity(0)
        case _ where cloudCondition < 35:
            Image("misty-clouds")
                .offset(y: 40)
                .opacity(0.6)
        case _ where cloudCondition < 55:
            Image("misty-clouds")
                .offset(y: 40)
        default:
            Image("misty-clouds")
                .offset(y: 40)
            Image("misty-clouds")
                .offset(y: 120)
        }
       
        //Rain
        if (dayData.days[weatherIndex].isRaining){
            SpriteView(scene: RainFall(), options: [.allowsTransparency])
                .frame(width: screenWidth, height: screenHeight)
                .ignoresSafeArea()
        }
        
    }
}


struct WeatherClock: View {
    
    let clockRotation: Angle
    let clockTime: String
    
    var body: some View {
        Image("Clock6")
            .scaleEffect(0.82)
            .rotationEffect(clockRotation, anchor: UnitPoint(x: 0.5, y: 0.5))
            .opacity(1.0)
        
        Text("\(clockTime)")
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(.white)
            .offset(y: -100)
        
        Image("ClockHands") //maybe instead of clock hands it says AM and PM with a symbol of the weather
            .offset(y: 160)
    }
    
    /*Image(systemName: "cloud") //maybe instead of clock hands it says AM and PM with a symbol of the weather
     .scaleEffect(5)
     .foregroundStyle(.white)
     .offset(y: 0)
     .offset(y: 340)*/
}

struct DayScreen: View {

    let temperature: String
    let screenColour: Color
    let weatherIcon: String
    let weatherText: String
    let screenWidth: Double
    
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: screenWidth)
                .foregroundColor(screenColour)
                .opacity(0.2)
            
            HStack() {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Image(systemName: weatherIcon)
                        .padding()
                        .scaleEffect(2.8)
                        .foregroundColor(.white)
                    Text(weatherText)
                        .font(.system(size: 25, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            .padding(22)
            .frame(width: screenWidth, alignment: .leading)
           // .border(Color.red, width: 3) //debug border
            .offset( y:-185)
            
            
            HStack {
                Text(temperature)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                Text("°")
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(.white)
                    .offset(x: -15, y:-30)
            }
                .frame(width: screenWidth, alignment: .trailing)
                .padding(-16)
                .offset( y:-185)
              //  .border(Color.red, width: 3)
            
            
        }
    }
    
}
    
class RainFall: SKScene {
    
    override func sceneDidLoad() {
        size = UIScreen.main.bounds.size
        scaleMode = .resizeFill
        
        anchorPoint = CGPoint(x: 0.5, y: 1)
        
        backgroundColor = .clear
        
        guard let node = SKEmitterNode(fileNamed: "Rainfall.sks") else { return }
        addChild(node)
        
        node.particlePositionRange.dx = UIScreen.main.bounds.width
    }
}

#Preview {
    
    let previewDayData: [WeatherHourItem] = [WeatherHourItem(location: "London", temp: "12", color: .black, time: "8", dayType: .day, conditionText: "It's Sunny"),
                                             WeatherHourItem(location: "London", temp: "13", color: .purple, time: "12", dayType: .day, conditionText: "It's Sunny")
                                                     ]
    
    let dayData:DayData = DayData(daysData: previewDayData)
    ContentView(dayData: dayData)
}



