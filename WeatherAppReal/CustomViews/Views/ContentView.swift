//
//  WAWeatherTilesContentView.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 06/01/2025.
//

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

enum DayType: String {
    case day, night
}

struct Coordinate: Identifiable{
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
}

struct DayData {
    static var days = [Item(location: "London", temp: "12", color: .black, time: "8", dayType: .day),
                       Item(location: "London", temp: "13", color: .purple, time: "12", dayType: .day),
                       Item(location: "London", temp: "16", color: .blue, time: "1", dayType: .day),
                       Item(location: "London", temp: "11", color: .purple, time: "3", dayType: .day),
                       Item(location: "London", temp: "11", color: .black, time: "5", dayType: .day),
                       Item(location: "London", temp: "9", color: .black, time: "8", dayType: .night),
                       Item(location: "London", temp: "8", color: .purple, time: "9", dayType: .night),
                       Item(location: "London", temp: "8", color: .purple, time: "10", dayType: .night),
                    Item(location: "London", temp: "7", color: .purple, time: "11", dayType: .night),
                       Item(location: "London", temp: "7", color: .black, time: "12", dayType: .night),
                      ]
    
    static var sun = [Coordinate(x: -180, y: 0),
                      Coordinate(x: -110, y: -70),
                      Coordinate(x: 0, y: -170),
                      Coordinate(x: 110, y: -70),
                      Coordinate(x: 180, y: 0)]
}

struct ContentView: View {
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    @State var sunX: CGFloat = DayData.sun[0].x
    @State var sunY: CGFloat = DayData.sun[0].y
    @State var sunIndex: Int = 0
    
    let weatherOffset: CGFloat = -UIScreen.main.bounds.width*1.02
    @State var weatherIndex = 0
    @State var weatherPos: CGFloat = (UIScreen.main.bounds.width * 4.59)
    
    @State var clockRotation: Angle = Angle(degrees: 0)
    @State var clockIncrement: Angle = Angle(degrees: 30)
    @State var clockTime: String = "12"
    
    @State var weatherAngle: Double = 0
    @State var landscapeAngle: Double = 0
    
    
    
    var body: some View {
        ZStack {
            
            WeatherEnvironment(skyColorAngle: weatherAngle, landscapeColorAngle: landscapeAngle, weatherIndex: weatherIndex, sunX: sunX, sunY: sunY)
            
            HStack {
                ForEach(DayData.days) { day in
                    
                    DayScreen(temperature: day.temp, screenColour: day.color, weatherIcon: "sun.max", weatherText: "It's Sunny", screenWidth: screenWidth)
                }
            }.offset(x:weatherPos, y: 0)
                .edgesIgnoringSafeArea(.all)
            
            LocationTimeDisplay(location: "London", timeString: "Today, Jan 13 12:04")
            .offset(x: -100, y:-330)
            .padding(16)

            WeatherClock(clockRotation: clockRotation, clockTime: clockTime)
                .offset(y: 390)
        }
        .swipe( left: {
            swipeLeft()
            getWeatherData()
        }, right: {
            swipeRight()
        })
    }
    
    func getWeatherData() {
        Task {
            do {
                let weatherReponse = try await WeatherAPIClient.shared.getAvgTemp(for: "sdfsdf", hour: 12)
                print(weatherReponse)
            } catch {
                print("Nooooo \(error.localizedDescription)")
            }
           
        }
    }
    
    func swipeLeft() {
        withAnimation {
            if(weatherIndex < DayData.days.count - 1){
                weatherIndex += 1
                weatherPos += weatherOffset
                clockRotation -= clockIncrement
                
                sunIndex += 1
                weatherAngle += 5
                
                if(sunIndex >= DayData.sun.count){ sunIndex = 0}
            }
            
            sunX = DayData.sun[sunIndex].x
            sunY = DayData.sun[sunIndex].y
            
            clockTime = DayData.days[weatherIndex].time
            
            if (DayData.days[weatherIndex].dayType == DayType.day){
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
                
                if(sunIndex < 0){ sunIndex = DayData.sun.count - 1}
            }
            sunX = DayData.sun[sunIndex].x
            sunY = DayData.sun[sunIndex].y
            
            clockTime = DayData.days[weatherIndex].time
            
            if (DayData.days[weatherIndex].dayType == DayType.day){
                landscapeAngle = 0
            }else{
                landscapeAngle = 155
            }
        }
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
                .offset(x: 16)
        }
    }
}

struct WeatherEnvironment: View {
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    let skyColorAngle: Double
    let landscapeColorAngle: Double
    let weatherIndex: Int
    let sunX: Double
    let sunY: Double
    
    var body: some View {
        Color(red: 55.8, green: 80, blue: 64.5, opacity: 1.0)
        Image("Sky").offset(y: -300)
            .hueRotation(.degrees(skyColorAngle))
        
        if (DayData.days[weatherIndex].dayType == DayType.day){
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
        Image("misty-clouds")
            .offset(y: 40)
        
        //Rain
        SpriteView(scene: RainFall(), options: [.allowsTransparency])
            .frame(width: screenWidth, height: screenHeight)
            .ignoresSafeArea()
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
            
            VStack(spacing: 30) {
                Image(systemName: weatherIcon)
                    .scaleEffect(2.8)
                    .foregroundColor(.white)
                    .offset(x:-25)
                Text(weatherText)
                    .font(.system(size: 25, weight: .regular))
                    .foregroundColor(.white)
            }.offset(x:-125, y:-185)
            
            HStack {
                Text(temperature)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("°")
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(.white)
                    .offset(x: -8, y:-30)
            } .offset(x:110, y:-190)
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

#Preview {ContentView()}
