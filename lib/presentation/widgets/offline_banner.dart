import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/simulation_manager.dart';
import '../../core/theme/app_colors.dart';
import '../cubits/debug/debug_simulation_cubit.dart';
import '../cubits/debug/debug_simulation_state.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebugSimulationCubit, DebugSimulationState>(
      builder: (context, state) {
        if (!state.isOffline && state.activeError == SimulatedErrorType.none) {
          return const SizedBox.shrink();
        }

        final isOffline = state.isOffline;
        final color = isOffline ? AppColors.warning : AppColors.error;
        final icon = isOffline ? Icons.wifi_off_rounded : Icons.bug_report_rounded;
        final message = isOffline
            ? 'Offline Mode Active • Showing cached data'
            : 'Debug Error Active: ${state.activeError.name}';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: color.withValues(alpha: 0.15),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
