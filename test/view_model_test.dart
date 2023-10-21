import 'package:flutter_test/flutter_test.dart';
import 'package:view_model/src/view_model.dart';

class TestViewModel extends ViewModel<int, int> {
  TestViewModel() : super(initialState: 0);
}

void main() {
  late TestViewModel viewModel;

  setUp(() {
    viewModel = TestViewModel();
  });

  tearDown(() {
    viewModel.close();
  });

  group("state", () {
    test("should return initial state", () {
      expect(viewModel.state, 0);
    });

    test("should return current state", () {
      viewModel.emitState(1);
      expect(viewModel.state, 1);
    });
  });

  group("lastEvent", () {
    test("should emit null if no event was emitted", () {
      expect(viewModel.lastEvent, null);
    });

    test("should emit last event", () {
      viewModel.emitEvent(1);
      expect(viewModel.lastEvent, 1);
    });
  });

  group("emitState", () {
    test("should emit states in correct order", () {
      expect(viewModel.stateStream, emitsInOrder([1, 2, 3, emitsDone]));
      viewModel.emitState(1);
      viewModel.emitState(2);
      viewModel.emitState(3);
      viewModel.close();
    });

    test("should not emit new states after close", () {
      expect(viewModel.stateStream, emitsInOrder([1, 2, emitsDone]));
      viewModel.emitState(1);
      viewModel.emitState(2);
      viewModel.close();
      viewModel.emitState(3);
    });

    test("should not emit the same state", () {
      expect(viewModel.stateStream, emitsInOrder([1, 2, emitsDone]));
      viewModel.emitState(1);
      viewModel.emitState(1);
      viewModel.emitState(2);
      viewModel.emitState(2);
      viewModel.close();
    });
  });

  group("emitEvent", () {
    test("should emit events in correct order", () {
      expect(viewModel.eventStream, emitsInOrder([1, 2, 3, emitsDone]));
      viewModel.emitEvent(1);
      viewModel.emitEvent(2);
      viewModel.emitEvent(3);
      viewModel.close();
    });

    test("should not emit new events after close", () {
      expect(viewModel.eventStream, emitsInOrder([1, 2, emitsDone]));
      viewModel.emitEvent(1);
      viewModel.emitEvent(2);
      viewModel.close();
      viewModel.emitEvent(3);
    });

    test("should allow emit the same event", () {
      expect(viewModel.eventStream, emitsInOrder([1, 1, 2, 2, emitsDone]));
      viewModel.emitEvent(1);
      viewModel.emitEvent(1);
      viewModel.emitEvent(2);
      viewModel.emitEvent(2);
      viewModel.close();
    });
  });

  group("close", () {
    test("should close stateStream", () {
      viewModel.close();
      expect(viewModel.eventStream, emitsDone);
    });

    test("should close eventStream", () {
      viewModel.close();
      expect(viewModel.eventStream, emitsDone);
    });
  });
}
