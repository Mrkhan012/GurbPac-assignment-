import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/simulation_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/debug/debug_simulation_cubit.dart';
import '../../cubits/debug/debug_simulation_state.dart';

class DebugPanelView extends StatelessWidget {
  const DebugPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebugSimulationCubit, DebugSimulationState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build_circle_outlined, size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Mock & Network Simulation',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.read<DebugSimulationCubit>().reset(),
                      child: const Text('Reset All', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simulated Offline Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Simulates loss of network and serves cached data', style: TextStyle(fontSize: 12)),
                  value: state.isOffline,
                  onChanged: (val) => context.read<DebugSimulationCubit>().toggleOffline(val),
                ),
                const SizedBox(height: 12),
                Text('Artificial Latency: ${state.delayMilliseconds} ms',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Slider(
                  value: state.delayMilliseconds.toDouble(),
                  min: 0,
                  max: 2000,
                  divisions: 20,
                  label: '${state.delayMilliseconds}ms',
                  onChanged: (val) => context.read<DebugSimulationCubit>().setDelay(val.toInt()),
                ),
                const SizedBox(height: 12),
                const Text('Simulate Error Response', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<SimulatedErrorType>(
                  initialValue: state.activeError,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: const [
                    DropdownMenuItem(value: SimulatedErrorType.none, child: Text('None (200 OK)')),
                    DropdownMenuItem(value: SimulatedErrorType.notFound404, child: Text('Simulated 404 - Not Found')),
                    DropdownMenuItem(value: SimulatedErrorType.serverError500, child: Text('Simulated 500 - Server Error')),
                    DropdownMenuItem(value: SimulatedErrorType.timeout408, child: Text('Simulated 408 - Timeout')),
                    DropdownMenuItem(value: SimulatedErrorType.validationError422, child: Text('Simulated 422 - Validation Error')),
                  ],
                  onChanged: (val) {
                    if (val != null) context.read<DebugSimulationCubit>().setErrorType(val);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
