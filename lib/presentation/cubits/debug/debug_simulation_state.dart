import 'package:equatable/equatable.dart';
import '../../../core/network/simulation_manager.dart';

class DebugSimulationState extends Equatable {
  final bool isOffline;
  final int delayMilliseconds;
  final SimulatedErrorType activeError;

  const DebugSimulationState({
    required this.isOffline,
    required this.delayMilliseconds,
    required this.activeError,
  });

  @override
  List<Object?> get props => [isOffline, delayMilliseconds, activeError];
}
