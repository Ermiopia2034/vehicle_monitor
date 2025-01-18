import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'lastKnownLocation') required String lastKnownLocation,
    @JsonKey(name: 'fuelLevel') required double fuelLevel,
    @JsonKey(name: 'batteryLevel') required double batteryLevel,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
