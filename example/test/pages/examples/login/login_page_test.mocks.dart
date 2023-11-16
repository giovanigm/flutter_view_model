// Mocks generated by Mockito 5.4.2 from annotations
// in example/test/pages/login/login_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:example/pages/examples/login/login_page_event.dart' as _i5;
import 'package:example/pages/examples/login/login_page_state.dart' as _i2;
import 'package:example/pages/examples/login/login_page_view_model.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLoginPageState_0 extends _i1.SmartFake
    implements _i2.LoginPageState {
  _FakeLoginPageState_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [LoginPageViewModel].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoginPageViewModel extends _i1.Mock
    implements _i3.LoginPageViewModel {
  @override
  bool get isClosed => (super.noSuchMethod(
        Invocation.getter(#isClosed),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  set isClosed(bool? _isClosed) => super.noSuchMethod(
        Invocation.setter(
          #isClosed,
          _isClosed,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.LoginPageState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _FakeLoginPageState_0(
          this,
          Invocation.getter(#state),
        ),
        returnValueForMissingStub: _FakeLoginPageState_0(
          this,
          Invocation.getter(#state),
        ),
      ) as _i2.LoginPageState);

  @override
  _i4.Stream<_i2.LoginPageState> get stateStream => (super.noSuchMethod(
        Invocation.getter(#stateStream),
        returnValue: _i4.Stream<_i2.LoginPageState>.empty(),
        returnValueForMissingStub: _i4.Stream<_i2.LoginPageState>.empty(),
      ) as _i4.Stream<_i2.LoginPageState>);

  @override
  _i4.Stream<_i5.LoginPageEvent> get eventStream => (super.noSuchMethod(
        Invocation.getter(#eventStream),
        returnValue: _i4.Stream<_i5.LoginPageEvent>.empty(),
        returnValueForMissingStub: _i4.Stream<_i5.LoginPageEvent>.empty(),
      ) as _i4.Stream<_i5.LoginPageEvent>);

  @override
  void setEmail(String? value) => super.noSuchMethod(
        Invocation.method(
          #setEmail,
          [value],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setPassword(String? value) => super.noSuchMethod(
        Invocation.method(
          #setPassword,
          [value],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<void> login() => (super.noSuchMethod(
        Invocation.method(
          #login,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  void emitState(_i2.LoginPageState? state) => super.noSuchMethod(
        Invocation.method(
          #emitState,
          [state],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void emitEvent(_i5.LoginPageEvent? event) => super.noSuchMethod(
        Invocation.method(
          #emitEvent,
          [event],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}