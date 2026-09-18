//
//  MagneticFieldScope.swift
//  ParticleSimulatorApp
//
//  Created by DY on 17/9/2026.
//  Copyright © 2026 Apple. All rights reserved.
//

/// For static function definitions
enum MagneticFieldFunctionScope {}

// TODO: Try to scope extension so conficts don't arise when integrating into globus

/// Namespace wrapper for type extensions
/// RxSwift/ .rx design pattern
protocol MagneticFieldTypeProtocol { associatedtype Storage }

/// Wrapper for generic magnetic field type
enum MagfieldTypeWrapper<T>: MagneticFieldTypeProtocol {typealias Storage = T}

/// For type specific extensions that are now only bound to within this scope
struct MagneticFieldTypeScope <typeOf: MagneticFieldTypeProtocol> {
    var raw: typeOf.Storage
    init(_ raw: typeOf.Storage) { self.raw = raw}
}

/// Scoped Type only used in MagneticField Layers
/// Call:
///
/// `MagneticFieldType( SIMD3<...> )`
typealias MagneticFieldType<T> = MagneticFieldTypeScope<MagfieldTypeWrapper<T>>
