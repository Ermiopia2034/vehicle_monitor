// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      lastKnownLocation: json['lastKnownLocation'] as String,
      fuelLevel: (json['fuelLevel'] as num).toDouble(),
      batteryLevel: (json['batteryLevel'] as num).toDouble(),
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'lastKnownLocation': instance.lastKnownLocation,
      'fuelLevel': instance.fuelLevel,
      'batteryLevel': instance.batteryLevel,
    };
