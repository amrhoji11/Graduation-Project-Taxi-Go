import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/vehicles/cubit/vehicle_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/driver_model.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';

class AdminVehiclesScreen extends StatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  State<AdminVehiclesScreen> createState() => _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends State<AdminVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VehicleCubit>().getVehicles();
  }

  Future<void> _refresh() async {
    await context.read<VehicleCubit>().getVehicles();
  }

  Future<void> _showAddVehicleDialog() async {
    final approvedDrivers = await context.read<VehicleCubit>().loadApprovedDrivers();

    if (!mounted) return;

    if (approvedDrivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.vehicleNoApprovedDrivers),
        ),
      );
      return;
    }

    _showVehicleDialog(approvedDrivers: approvedDrivers);
  }

  void _showEditVehicleDialog(VehicleModel vehicle) {
    _showVehicleDialog(vehicle: vehicle);
  }

  void _showVehicleDialog({
    VehicleModel? vehicle,
    List<DriverModel> approvedDrivers = const [],
  }) {
    String? selectedDriverId = vehicle?.driverId;
    final plateController = TextEditingController(
      text: vehicle?.plateNumber ?? '',
    );
    final makeController = TextEditingController(
      text: vehicle?.make ?? '',
    );
    final modelController = TextEditingController(
      text: vehicle?.model ?? '',
    );
    final colorController = TextEditingController(
      text: vehicle?.color ?? '',
    );
    final yearController = TextEditingController(
      text: vehicle?.year?.toString() ?? '',
    );
    final seatsController = TextEditingController(
      text: vehicle?.seats.toString() ?? '',
    );
    final readOnlyDriverController = TextEditingController(
      text: vehicle?.driverName ?? vehicle?.driverId ?? '',
    );
    VehicleSize selectedSize = vehicle?.vehicleSize ?? VehicleSize.small;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(vehicle == null ? l10n.vehicleAddTitle : l10n.vehicleEditTitle),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (vehicle == null) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedDriverId,
                        decoration: InputDecoration(
                          labelText: l10n.vehicleDriverApprovedOnly,
                        ),
                        items: approvedDrivers
                            .map(
                              (driver) => DropdownMenuItem(
                                value: driver.userId,
                                child: Text(driver.name ?? driver.userId),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedDriverId = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ] else
                      AppTextField(
                        controller: readOnlyDriverController,
                        enabled: false,
                        label: l10n.commonDriver,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: plateController,
                      label: l10n.vehiclePlateNumber,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: makeController,
                      label: l10n.vehicleMakeHint,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(controller: modelController, label: l10n.commonModel),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(controller: colorController, label: l10n.commonColor),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: seatsController,
                      keyboardType: TextInputType.number,
                      label: l10n.vehicleSeats,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      label: l10n.vehicleYearOptional,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<VehicleSize>(
                      initialValue: selectedSize,
                      decoration: InputDecoration(
                        labelText: l10n.vehicleSize,
                      ),
                      items: VehicleSize.values
                          .map(
                            (size) => DropdownMenuItem(
                              value: size,
                              child: Text(size.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedSize = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final plate = plateController.text.trim();
                    final make = makeController.text.trim();
                    final model = modelController.text.trim();
                    final color = colorController.text.trim();
                    final seats = int.tryParse(seatsController.text.trim());
                    final year = int.tryParse(yearController.text.trim());

                    if (plate.isEmpty || model.isEmpty || color.isEmpty || seats == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.vehicleFillRequiredFields),
                        ),
                      );
                      return;
                    }

                    if (vehicle == null && selectedDriverId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.vehicleSelectDriverForVehicle),
                        ),
                      );
                      return;
                    }

                    if (vehicle == null) {
                      context.read<VehicleCubit>().addVehicle(
                        driverId: selectedDriverId!,
                        plateNumber: plate,
                        make: make,
                        model: model,
                        color: color,
                        vehicleSize: selectedSize,
                        seats: seats,
                        year: year,
                      );
                    } else {
                      context.read<VehicleCubit>().updateVehicle(
                        vehicleId: vehicle.id,
                        plateNumber: plate,
                        make: make,
                        model: model,
                        color: color,
                        vehicleSize: selectedSize,
                        seats: seats,
                        year: year,
                      );
                    }

                    Navigator.pop(dialogContext);
                  },
                  child: Text(vehicle == null ? l10n.commonAdd : l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      plateController.dispose();
      makeController.dispose();
      modelController.dispose();
      colorController.dispose();
      yearController.dispose();
      seatsController.dispose();
      readOnlyDriverController.dispose();
    });
  }

  Future<void> _showAssignVehicleDialog(VehicleModel vehicle) async {
    final approvedDrivers = await context.read<VehicleCubit>().loadApprovedDrivers();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (approvedDrivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.vehicleNoApprovedDrivers),
        ),
      );
      return;
    }

    String? selectedDriverId;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(l10n.vehicleAssignTitle),
              content: DropdownButtonFormField<String>(
                initialValue: selectedDriverId,
                decoration: InputDecoration(
                  labelText: l10n.vehicleDriverApprovedOnly,
                ),
                items: approvedDrivers
                    .map(
                      (driver) => DropdownMenuItem(
                        value: driver.userId,
                        child: Text(driver.name ?? driver.userId),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedDriverId = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDriverId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.vehicleSelectDriver),
                        ),
                      );
                      return;
                    }

                    context.read<VehicleCubit>().assignVehicle(
                      vehicleId: vehicle.id,
                      driverId: selectedDriverId!,
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.commonAssign),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleCubit, VehicleState>(
      listener: (context, state) {
        if (state is VehicleActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is VehicleFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.vehicleManageTitle),
            actions: [
              IconButton(
                onPressed: _showAddVehicleDialog,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, VehicleState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is VehicleLoading) {
      return const AppLoading();
    }

    if (state is VehiclesLoaded) {
      final vehicles = state.vehicles;

      if (vehicles.isEmpty) {
        return AppEmptyState(
          icon: Icons.directions_car_outlined,
          title: l10n.vehicleNoVehiclesFound,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];

            return _VehicleCard(
              vehicle: vehicle,
              onEdit: () => _showEditVehicleDialog(vehicle),
              onAssign: () => _showAssignVehicleDialog(vehicle),
              onUnassign: () {
                context.read<VehicleCubit>().unassignVehicle(vehicle.id);
              },
              onChangeStatus: () {
                context.read<VehicleCubit>().changeVehicleStatus(vehicle.id);
              },
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.directions_car_outlined,
      title: l10n.vehicleNoVehiclesLoaded,
      actionLabel: l10n.vehicleLoadVehicles,
      onAction: _refresh,
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onUnassign;
  final VoidCallback onChangeStatus;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onAssign,
    required this.onUnassign,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                backgroundImage: vehicle.platePhotoUrl != null
                    ? NetworkImage(vehicle.platePhotoUrl!)
                    : null,
                child: vehicle.platePhotoUrl == null
                    ? const Icon(Icons.directions_car, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.plateNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.make} ${vehicle.model} - ${vehicle.color}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${l10n.vehicleSeatsLabel} ${vehicle.seats} • ${l10n.vehicleSizeLabel} ${vehicle.vehicleSize.label}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${l10n.commonDriver}: ${vehicle.driverName ?? vehicle.driverId ?? l10n.vehicleDriverNotAssigned}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              AppStatusChip(
                label: vehicle.isActive ? l10n.commonActive : l10n.commonInactive,
                tone: vehicle.isActive
                    ? AppStatusTone.success
                    : AppStatusTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppPrimaryButton(
                label: l10n.commonEdit,
                expand: false,
                onPressed: onEdit,
              ),
              AppPrimaryButton(
                label: l10n.commonAssign,
                expand: false,
                onPressed: vehicle.driverId == null ? onAssign : null,
              ),
              AppSecondaryButton(
                label: l10n.vehicleUnassign,
                expand: false,
                onPressed: vehicle.driverId != null ? onUnassign : null,
              ),
              AppSecondaryButton(
                label: l10n.vehicleChangeStatus,
                expand: false,
                onPressed: onChangeStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
