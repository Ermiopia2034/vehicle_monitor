import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../services/firebase_service.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  ConsumerState<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fuelController;
  late TextEditingController _batteryController;
  late String _selectedStatus;
  bool _isLoading = false;
  bool _statusManuallyChanged = false;

  static const List<Color> cardColors = [
    Color(0xFF90C99E),  // Soft green
    Color(0xFF7EA8D6),  // Soft blue
    Color(0xFFE88B8B),  // Soft red
  ];

  Color getCardColor(int index) {
    return cardColors[index % cardColors.length];
  }

  @override
  void initState() {
    super.initState();
    _fuelController = TextEditingController();
    _batteryController = TextEditingController();
  }

  @override
  void dispose() {
    _fuelController.dispose();
    _batteryController.dispose();
    super.dispose();
  }

  void _updateControllers(Vehicle vehicle) {
    if (!mounted) return;
    setState(() {
      _fuelController.text = vehicle.fuelLevel.toString();
      _batteryController.text = vehicle.batteryLevel.toString();
      if (!_statusManuallyChanged) {
        _selectedStatus = vehicle.status;
      }
    });
  }

  Widget _buildStatusDropdown(List<String> options) {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.sync),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      items: options.map((status) {
        final color = _getStatusColor(status);
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                status == 'Active' 
                    ? Icons.check_circle 
                    : status == 'Maintenance' 
                        ? Icons.build 
                        : Icons.error,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(color: color),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
            _statusManuallyChanged = true;
          });
        }
      },
    );
  }

  Future<void> _updateVehicle(Vehicle vehicle) async {
    try {
      final oldStatus = vehicle.status;
      final oldFuel = vehicle.fuelLevel;
      final oldBattery = vehicle.batteryLevel;

      final newFuel = double.parse(_fuelController.text);
      final newBattery = double.parse(_batteryController.text);

      bool hasChanges = _statusManuallyChanged || 
                       oldFuel != newFuel || 
                       oldBattery != newBattery;

      if (!hasChanges) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes to update'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final updatedVehicle = vehicle.copyWith(
        status: _selectedStatus,
        fuelLevel: newFuel,
        batteryLevel: newBattery,
      );

      await ref.read(firebaseServiceProvider).updateVehicle(updatedVehicle);
      
      if (mounted) {
        _showUpdateSuccessDialog(
          oldStatus: oldStatus,
          newStatus: _selectedStatus,
          oldFuel: oldFuel,
          newFuel: newFuel,
          oldBattery: oldBattery,
          newBattery: newBattery,
        );
        _statusManuallyChanged = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUpdateSuccessDialog({
    required String oldStatus,
    required String newStatus,
    required double oldFuel,
    required double newFuel,
    required double oldBattery,
    required double newBattery,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade300,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Vehicle Updated',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Successfully updated the following:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (oldStatus != newStatus) Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sync, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Previous',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                oldStatus,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _getStatusColor(oldStatus),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'New',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                newStatus,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _getStatusColor(newStatus),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (oldFuel != newFuel) _buildChangeRow(
                icon: Icons.local_gas_station,
                label: 'Fuel Level',
                oldValue: '${oldFuel.toStringAsFixed(1)}%',
                newValue: '${newFuel.toStringAsFixed(1)}%',
                oldColor: _getLevelColor(oldFuel),
                newColor: _getLevelColor(newFuel),
              ),
              if (oldBattery != newBattery) _buildChangeRow(
                icon: Icons.battery_charging_full,
                label: 'Battery Level',
                oldValue: '${oldBattery.toStringAsFixed(1)}%',
                newValue: '${newBattery.toStringAsFixed(1)}%',
                oldColor: _getLevelColor(oldBattery),
                newColor: _getLevelColor(newBattery),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(double value) {
    if (value > 50) {
      return Colors.green.shade300;
    } else if (value > 20) {
      return Colors.orange.shade300;
    } else {
      return Colors.red.shade300;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green.shade300;
      case 'Maintenance':
        return Colors.orange.shade300;
      case 'Inactive':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _buildChangeRow({
    required IconData icon,
    required String label,
    required String oldValue,
    required String newValue,
    Color? oldColor,
    Color? newColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      oldValue,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: oldColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.grey,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'New',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      newValue,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: newColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehicleStreamProvider(widget.vehicleId));
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(errorProvider);
    final statusOptions = ref.watch(vehicleStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: vehicle.when(
        data: (vehicle) {
          if (vehicle == null) {
            return const Center(
              child: Text('Vehicle not found'),
            );
          }

          if (!_isLoading) {
            _updateControllers(vehicle);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vehicleStreamProvider(widget.vehicleId));
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            color: Colors.red.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => ref.read(errorProvider.notifier).state = null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: getCardColor(0).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getCardColor(0).withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vehicle Information',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: getCardColor(0).withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  label: 'Name',
                                  value: vehicle.name,
                                  icon: Icons.directions_car,
                                  color: getCardColor(0),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  label: 'Location',
                                  value: vehicle.lastKnownLocation,
                                  icon: Icons.location_on,
                                  color: getCardColor(0),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  label: 'Status',
                                  value: vehicle.status,
                                  icon: Icons.info_outline,
                                  color: getCardColor(0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: getCardColor(1).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getCardColor(1).withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Update Vehicle',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: getCardColor(1).withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatusDropdown(statusOptions),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _fuelController,
                                    decoration: const InputDecoration(
                                      labelText: 'Fuel Level',
                                      border: OutlineInputBorder(),
                                      suffixText: '%',
                                      prefixIcon: Icon(Icons.local_gas_station),
                                      helperText: 'Enter a value between 0 and 100',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a fuel level';
                                      }
                                      final number = double.tryParse(value);
                                      if (number == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (number < 0 || number > 100) {
                                        return 'Fuel level must be between 0 and 100';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _batteryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Battery Level',
                                      border: OutlineInputBorder(),
                                      suffixText: '%',
                                      prefixIcon: Icon(Icons.battery_charging_full),
                                      helperText: 'Enter a value between 0 and 100',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a battery level';
                                      }
                                      final number = double.tryParse(value);
                                      if (number == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (number < 0 || number > 100) {
                                        return 'Battery level must be between 0 and 100';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!.validate()) {
                                                return;
                                              }
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              await _updateVehicle(vehicle);
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (_isLoading)
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else
                                            const Icon(Icons.save),
                                          const SizedBox(width: 8),
                                          Text(_isLoading ? 'Updating...' : 'Update Vehicle'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
