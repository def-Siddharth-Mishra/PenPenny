import 'package:events_emitter/emitters/event_emitter.dart';

enum GlobalEventType {
  paymentUpdate,
  categoryUpdate,
  accountUpdate,
  settingsUpdate,
}

final globalEventEmitter = EventEmitter();