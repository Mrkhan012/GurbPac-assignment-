import 'dart:async';
import '../errors/exceptions.dart';

enum SimulatedErrorType {
  none,
  notFound404,
  serverError500,
  timeout408,
  validationError422,
}

class SimulationManager {
  static final SimulationManager _instance = SimulationManager._internal();
  factory SimulationManager() => _instance;
  SimulationManager._internal();

  bool isOffline = false;
  int delayMilliseconds = 400;
  SimulatedErrorType activeError = SimulatedErrorType.none;

  final _changeController = StreamController<bool>.broadcast();
  Stream<bool> get onOfflineStatusChanged => _changeController.stream;

  void setOffline(bool offline) {
    if (isOffline != offline) {
      isOffline = offline;
      _changeController.add(isOffline);
    }
  }

  void setDelay(int milliseconds) {
    delayMilliseconds = milliseconds;
  }

  void setErrorType(SimulatedErrorType errorType) {
    activeError = errorType;
  }

  Future<void> simulateNetworkCall() async {
    if (isOffline) {
      throw const NetworkException('Device is currently offline');
    }

    if (delayMilliseconds > 0) {
      await Future.delayed(Duration(milliseconds: delayMilliseconds));
    }

    switch (activeError) {
      case SimulatedErrorType.notFound404:
        throw const NotFoundException('Simulated 404: Resource not found');
      case SimulatedErrorType.serverError500:
        throw const ServerException('Simulated 500: Internal server error');
      case SimulatedErrorType.timeout408:
        throw const TimeoutException('Simulated 408: Connection timed out');
      case SimulatedErrorType.validationError422:
        throw const ValidationException('Simulated 422: Unprocessable entity');
      case SimulatedErrorType.none:
        break;
    }
  }

  void reset() {
    isOffline = false;
    delayMilliseconds = 400;
    activeError = SimulatedErrorType.none;
    _changeController.add(false);
  }
}
