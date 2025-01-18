import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vehicle';

  // Get all vehicles with real-time updates
  Stream<List<Vehicle>> getVehicles() {
    try {
      return _firestore
          .collection(_collection)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Vehicle.fromJson({
                    'id': doc.id,
                    'name': doc.data()['name'] ?? '',
                    'status': doc.data()['status'] ?? '',
                    'lastKnownLocation': doc.data()['lastKnownLocation'] ?? '',
                    'fuelLevel': (doc.data()['fuelLevel'] ?? 0).toDouble(),
                    'batteryLevel': (doc.data()['batteryLevel'] ?? 0).toDouble(),
                  }))
              .toList());
    } catch (e) {
      print('Error getting vehicles: $e');
      rethrow;
    }
  }

  // Get a single vehicle with real-time updates
  Stream<Vehicle?> getVehicleStream(String id) {
    try {
      return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
        if (!doc.exists) return null;
        return Vehicle.fromJson({
          'id': doc.id,
          'name': doc.data()?['name'] ?? '',
          'status': doc.data()?['status'] ?? '',
          'lastKnownLocation': doc.data()?['lastKnownLocation'] ?? '',
          'fuelLevel': (doc.data()?['fuelLevel'] ?? 0).toDouble(),
          'batteryLevel': (doc.data()?['batteryLevel'] ?? 0).toDouble(),
        });
      });
    } catch (e) {
      print('Error getting vehicle stream: $e');
      rethrow;
    }
  }

  // Get a single vehicle (one-time fetch)
  Future<Vehicle?> getVehicle(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return Vehicle.fromJson({
        'id': doc.id,
        'name': doc.data()?['name'] ?? '',
        'status': doc.data()?['status'] ?? '',
        'lastKnownLocation': doc.data()?['lastKnownLocation'] ?? '',
        'fuelLevel': (doc.data()?['fuelLevel'] ?? 0).toDouble(),
        'batteryLevel': (doc.data()?['batteryLevel'] ?? 0).toDouble(),
      });
    } catch (e) {
      print('Error getting vehicle: $e');
      rethrow;
    }
  }

  // Update vehicle with optimistic updates
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      // Create a map with the exact field names as in Firestore
      final Map<String, dynamic> updateData = {
        'name': vehicle.name,
        'status': vehicle.status,
        'lastKnownLocation': vehicle.lastKnownLocation,
        'fuelLevel': vehicle.fuelLevel,
        'batteryLevel': vehicle.batteryLevel,
      };

      print('Updating vehicle with data: $updateData'); // Debug print

      await _firestore
          .collection(_collection)
          .doc(vehicle.id)
          .update(updateData)
          .then((_) {
        print('Update successful in Firestore'); // Debug print
      }).catchError((error) {
        print('Error in Firestore update: $error'); // Debug print
        throw error;
      });
    } catch (e) {
      print('Error updating vehicle: $e');
      rethrow;
    }
  }

  // Watch for vehicle status changes
  Stream<List<Vehicle>> getVehiclesByStatus(String status) {
    try {
      return _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Vehicle.fromJson({
                    'id': doc.id,
                    'name': doc.data()['name'] ?? '',
                    'status': doc.data()['status'] ?? '',
                    'lastKnownLocation': doc.data()['lastKnownLocation'] ?? '',
                    'fuelLevel': (doc.data()['fuelLevel'] ?? 0).toDouble(),
                    'batteryLevel': (doc.data()['batteryLevel'] ?? 0).toDouble(),
                  }))
              .toList());
    } catch (e) {
      print('Error getting vehicles by status: $e');
      rethrow;
    }
  }
}
