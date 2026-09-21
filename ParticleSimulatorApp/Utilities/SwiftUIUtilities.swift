//
//  SwiftUIUtilities.swift
//  ParticleSimulatorApp
//
//  Created by DY on 15/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//
import SwiftUI

/// Shows slider with a number label to the right; for discrete step count
func sliderWithNumbersShown<V>(value: Binding<V>,
                               in range: ClosedRange<V>,
                               precision: Int = 2,
                               step: V.Stride = 1)
-> some View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    
    HStack {
        Slider(value: value, in: range, step: step)
            .transaction { $0.animation = nil }
            .padding(.horizontal, 20)
        Text(Double(value.wrappedValue), format: .number.precision(.fractionLength(precision)))
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
                               in range: ClosedRange<V>,
                               precision: Int = 2)
-> some View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    HStack {
        Slider(value: value, in: range)
            .transaction { $0.animation = nil }
            .padding(.horizontal, 20)
        Text(Double(value.wrappedValue), format: .number.precision(.fractionLength(precision)))
            .font(.title2)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
    }
}

