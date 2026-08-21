import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/simulation_manager.dart';
import 'debug_simulation_state.dart';

class DebugSimulationCubit extends Cubit<DebugSimulationState> {
  final SimulationManager _simulationManager;

  DebugSimulationCubit({required SimulationManager simulationManager})
      : _simulationManager = simulationManager,
        super(DebugSimulationState(
          isOffline: simulationManager.isOffline,
          delayMilliseconds: simulationManager.delayMilliseconds,
          activeError: simulationManager.activeError,
        ));

  void toggleOffline(bool offline) {
    _simulationManager.setOffline(offline);
    emit(DebugSimulationState(
      isOffline: offline,
      delayMilliseconds: state.delayMilliseconds,
      activeError: state.activeError,
    ));
  }

  void setDelay(int ms) {
    _simulationManager.setDelay(ms);
    emit(DebugSimulationState(
      isOffline: state.isOffline,
      delayMilliseconds: ms,
      activeError: state.activeError,
    ));
  }

  void setErrorType(SimulatedErrorType errorType) {
    _simulationManager.setErrorType(errorType);
    emit(DebugSimulationState(
      isOffline: state.isOffline,
      delayMilliseconds: state.delayMilliseconds,
      activeError: errorType,
    ));
  }

  void reset() {
    _simulationManager.reset();
    emit(const DebugSimulationState(
      isOffline: false,
      delayMilliseconds: 400,
      activeError: SimulatedErrorType.none,
    ));
  }
}
