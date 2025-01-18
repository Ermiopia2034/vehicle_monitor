import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesStream = ref.watch(vehiclesStreamProvider);
    final error = ref.watch(errorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Monitor'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          if (error != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(16),
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
          Expanded(
            child: vehiclesStream.when(
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull to refresh when vehicles are added',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(vehiclesStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return _VehicleCard(vehicle: vehicle, index: index);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading vehicles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(vehiclesStreamProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  static const List<Color> cardColors = [
    Color(0xFF90C99E),  // Soft green
    Color(0xFF7EA8D6),  // Soft blue
    Color(0xFFE88B8B),  // Soft red
    Color(0xFFE8C28B),  // Soft orange
    Color(0xFFB088E8),  // Soft purple
  ];

  final Vehicle vehicle;
  final int index;

  const _VehicleCard({
    required this.vehicle,
    required this.index,
  });

  Color getCardColor(int index) {
    return cardColors[index % cardColors.length];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'idle':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'idle':
        return Icons.pause_circle;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(vehicle.status);
    final statusIcon = _getStatusIcon(vehicle.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => context.push('/vehicle/${vehicle.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getCardColor(index).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getCardColor(index).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vehicle.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: getCardColor(index).withOpacity(0.9),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.status == 'Active'
                          ? Colors.green.withOpacity(0.2)
                          : vehicle.status == 'Maintenance'
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.status,
                          style: TextStyle(
                            color: vehicle.status == 'Active'
                                ? Colors.green.shade300
                                : vehicle.status == 'Maintenance'
                                    ? Colors.orange.shade300
                                    : Colors.red.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: getCardColor(index).withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vehicle.lastKnownLocation,
                                style: TextStyle(
                                  color: getCardColor(index).withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _LevelIndicator(
                          label: 'Fuel Level',
                          icon: Icons.local_gas_station,
                          value: vehicle.fuelLevel,
                          isFuel: true,
                        ),
                        const SizedBox(height: 8),
                        _LevelIndicator(
                          label: 'Battery Level',
                          icon: Icons.battery_charging_full,
                          value: vehicle.batteryLevel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final bool isFuel;

  const _LevelIndicator({
    required this.label,
    required this.icon,
    required this.value,
    this.isFuel = false,
  });

  Color _getColor(double value) {
    if (value <= 20) {
      return Colors.red;
    } else if (value <= 40) {
      return Colors.orange;
    } else {
      return isFuel ? Colors.green : Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              value > 50
                  ? Colors.green.shade300
                  : value > 20
                      ? Colors.orange.shade300
                      : Colors.red.shade300,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
