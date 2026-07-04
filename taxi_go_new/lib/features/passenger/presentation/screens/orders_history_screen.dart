import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/theme/status_tone.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/order_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/order_detail_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/order_model.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getOrders();
  }

  Future<void> _openDetail(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order.orderId),
      ),
    );

    if (!mounted) return;
    context.read<OrderCubit>().getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.passengerMyOrders)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrderState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is OrderLoading) {
      return const AppLoading();
    }

    if (state is OrdersLoaded) {
      if (state.orders.isEmpty) {
        return AppEmptyState(
          icon: Icons.local_taxi_outlined,
          title: l10n.passengerOrdersEmptyTitle,
          subtitle: l10n.passengerOrdersEmptySubtitle,
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderCubit>().getOrders();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: state.orders.length,
          itemBuilder: (context, index) {
            final order = state.orders[index];

            return AppCard(
              onTap: () => _openDetail(order),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.dropoffLocation != null
                              ? '${order.pickupLocation} → ${order.dropoffLocation}'
                              : order.pickupLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        AppStatusChip(
                          label: order.status.label,
                          tone: orderStatusTone(order.status),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            );
          },
        ),
      );
    }

    return AppErrorState(
      message: state is OrderFailure ? state.message : l10n.passengerOrdersLoadError,
      onRetry: () => context.read<OrderCubit>().getOrders(),
    );
  }
}
