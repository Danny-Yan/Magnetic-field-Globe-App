//
//  SwiftUIUtilities.swift
//  ParticleSimulatorApp
//
//  Created by DY on 15/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import SwiftUI

extension View {
    func disabledFully(_ isDisabled: Bool) -> some View {
        self
            .disabled(isDisabled)
            .allowsHitTesting(!isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
    }
}


/// Shows slider with a number label to the right
func sliderWithNumbersShown<V>(value: Binding<V>,
                     in range: ClosedRange<V>,
                        step: V.Stride = 1) -> some View
                    where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        
    HStack {
        Slider(value: value, in: range, step: step)
            .transaction { $0.animation = nil }
            .padding(.horizontal, 20)
        Text("\(value.wrappedValue, default: "%.1f")" as String)
            .font(.title2)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
    }
}

/// Shows slider with a number label to the right
func sliderWithNumbersShown<V>(value: Binding<V>,
                     in range: ClosedRange<V>) -> some View
                    where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    HStack {
        Slider(value: value, in: range)
            .transaction { $0.animation = nil }
            .padding(.horizontal, 20)
        Text("\(value.wrappedValue, default: "%.1f")" as String)
            .font(.title2)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
    }
}
