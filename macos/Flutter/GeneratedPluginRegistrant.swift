//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import gal
import geolocator_apple
import package_info_plus
import reactive_ble_mobile
import shared_preferences_foundation

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  GalPlugin.register(with: registry.registrar(forPlugin: "GalPlugin"))
  GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  ReactiveBlePlugin.register(with: registry.registrar(forPlugin: "ReactiveBlePlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}
