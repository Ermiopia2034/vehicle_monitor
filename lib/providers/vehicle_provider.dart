import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../services/firebase_service.dart';

// Stream of all vehicles
final vehiclesStreamProvider = StreamProvider<List<Vehicle>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getVehicles();
});

// Stream of a single vehicle
final vehicleStreamProvider = StreamProvider.family<Vehicle?, String>((ref, id) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getVehicleStream(id);
});

// Stream of vehicles filtered by status
final vehiclesByStatusProvider = StreamProvider.family<List<Vehicle>, String>((ref, status) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getVehiclesByStatus(status);
});

// Currently selected vehicle
final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);

// Available vehicle statuses
final vehicleStatusProvider = Provider<List<String>>((ref) {
  return ['Active', 'Idle', 'Maintenance'];
});

// Loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Error state
final errorProvider = StateProvider<String?>((ref) => null);
