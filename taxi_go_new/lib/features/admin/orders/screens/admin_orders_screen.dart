import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/admin/orders/cubit/admin_orders_cubit.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/admin_order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminOrdersCubit>().getOrders();
  }

  Future<void> _refresh() async {
    await context.read<AdminOrdersCubit>().getOrders();
  }

  Future<void> _showAssignDriverDialog(AdminOrderModel order) async {
    final cubit = context.read<AdminOrdersCubit>();
    final l10n = AppLocalizations.of(context)!;
    final drivers = await cubit.loadAssignableDrivers();

    if (!mounted) return;

    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminNoAssignableDrivers)),
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
              title: Text('${l10n.adminAssignDriverToOrder}${order.orderId}'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedDriverId,
                decoration: InputDecoration(labelText: l10n.commonDriver),
                items: drivers
                    .map(
                      (driver) => DropdownMenuItem(
                        value: driver.userId,
                        child: Text(
                          '${driver.name ?? driver.userId} (${driver.status.label})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedDriverId = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDriverId == null) return;
                    Navigator.pop(dialogContext);
                    cubit.manualAssignOrder(
                      orderId: order.orderId,
                      driverId: selectedDriverId!,
                    );
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
    return BlocConsumer<AdminOrdersCubit, AdminOrdersState>(
      listener: (context, state) {
        if (state is AdminOrdersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminOrders)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdminOrdersState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is AdminOrdersLoading) {
      return const AppLoading();
    }

    if (state is AdminOrdersFailure) {
      return AppErrorState(message: state.message, onRetry: _refresh);
    }

    if (state is AdminOrdersLoaded) {
      final orders = state.result.data;

      if (orders.isEmpty) {
        return AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.adminNoOrdersFound,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              onAssignDriver: () => _showAssignDriverDialog(order),
            );
          },
        ),
      );
    }

    return AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.adminNoOrdersLoaded,
      actionLabel: l10n.adminLoadOrders,
      onAction: _refresh,
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AdminOrderModel order;
  final VoidCallback onAssignDriver;

  const _OrderCard({required this.order, required this.onAssignDriver});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAssign = order.status != OrderStatusType.completed &&
        order.status != OrderStatusType.cancelled;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.receipt_long, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.orderDetailOrderHash}${order.orderId} - ${order.passengerName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.adminOrderFromPrefix} ${order.pickupLocation}\n'
                      '${l10n.adminOrderToPrefix} ${order.dropoffLocation ?? l10n.commonNA}\n'
                      '${l10n.commonPassengers}: ${order.passengerCount} • ${l10n.createOrderPriority}: ${order.priority.label}'
                      '${order.tripId != 0 ? '\n${l10n.driverTripHash}${order.tripId}' : ''}'
                      '${order.rating?.stars != null ? '\n${l10n.adminOrderRatingPrefix} ${order.rating!.stars}/5' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              AppStatusChip(
                label: order.status.label,
                tone: orderStatusTone(order.status),
              ),
            ],
          ),
          if (canAssign) ...[
            const SizedBox(height: AppSpacing.sm),
            AppSecondaryButton(
              label: l10n.adminAssignDriverButton,
              icon: Icons.person_add_alt_outlined,
              expand: false,
              onPressed: onAssignDriver,
            ),
          ],
        ],
      ),
    );
  }
}
