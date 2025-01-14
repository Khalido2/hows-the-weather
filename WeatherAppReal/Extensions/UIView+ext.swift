//
//  UIView+ext.swift
//  WeatherAppReal
//
//  Created by "Khalid Olowe-Makorie, Vodafone" on 04/12/2024.
//
import UIKit
import SwiftUI

extension UIView {
    
    func addSubViews(_ views: UIView...){
        for subview in views {
            subview.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(subview)
        }
    }
}

extension View {
    func swipe(
        up: @escaping (() -> Void) = {},
        down: @escaping (() -> Void) = {},
        left: @escaping (() -> Void) = {},
        right: @escaping (() -> Void) = {}
    ) -> some View {
        return self.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
            .onEnded { value in
                switch(value.translation.width, value.translation.height) {
                    case (...0, -30...30):  left()
                    case (0..., -30...30):  right()
                    case (-100...100, ...0):  up()
                    case (-100...100, 0...):  down()
                    default:  print("no clue what swipe that was")
                }
            }
        )
    }
}

