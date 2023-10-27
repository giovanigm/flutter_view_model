import 'package:example/page/login/login_page.dart';
import 'package:example/page/widgets/example_text_field.dart';
import 'package:example/page/widgets/loading_overlay.dart';
import 'package:example/view_model/login/login_event.dart';
import 'package:example/view_model/login/login_state.dart';
import 'package:example/view_model/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:view_model/view_model.dart';

import 'login_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<LoginViewModel>()])
void main() {
  group("Login Page", () {
    group('Mock ViewModel', () {
      late LoginViewModel viewModel;

      setUp(() {
        viewModel = MockLoginViewModel();
      });

      testWidgets("Should render initial state correctly",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginState.initialState());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets("Should render invalid email state correctly",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().invalidEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == 'Invalid email' &&
                widget.success == false &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets("Should render email not found state correctly",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().emailNotFound());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == 'Email not found' &&
                widget.success == false &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets("Should render invalid password state correctly",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().invalidPassword());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText ==
                    'Password must have at least 6 characters' &&
                widget.success == false &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets("Should render incorrect password state correctly",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().incorrectPassword());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == 'Incorrect password' &&
                widget.success == false &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets(
          "Should disable button if email is valid and password is invalid",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().validEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == true &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets(
          "Should disable button if email is invalid and password is valid",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().validPassword());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == false &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == true &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed == null),
            findsOneWidget);
      });

      testWidgets("Should enable button on success state",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().validPassword().validEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == true &&
                widget.hintText == 'Email'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is ExampleTextField &&
                widget.errorText == null &&
                widget.success == true &&
                widget.hintText == 'Password'),
            findsOneWidget);
        expect(
            find.byWidgetPredicate(
                (widget) => widget is FilledButton && widget.onPressed != null),
            findsOneWidget);
      });

      testWidgets("Should call login on button tap", (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginState.initialState().validPassword().validEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        await widgetTester.tap(find.byType(FilledButton));

        verify(viewModel.login());
      });

      testWidgets("Should show loading on startLoadingEvent",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginState.initialState());

        final broadcastStream =
            Stream.value(LoadingLoginEvent.open()).asBroadcastStream();
        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        await widgetTester.pumpWidget(MaterialApp(
            builder: (context, child) => LoadingOverlay(child: child!),
            home: ViewModelProvider<LoginViewModel>(
              create: (context) => viewModel,
              child: const LoginPage(),
            )));

        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets("Should close loading on stopLoadingEvent",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginState.initialState());

        final broadcastStream =
            Stream.value(LoadingLoginEvent.close()).asBroadcastStream();

        when(viewModel.lastEvent).thenReturn(LoadingLoginEvent.open());
        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        await widgetTester.pumpWidget(MaterialApp(
            builder: (context, child) => LoadingOverlay(child: child!),
            home: ViewModelProvider<LoginViewModel>(
              create: (context) => viewModel,
              child: const LoginPage(),
            )));

        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets("Should change page correctly on navigate event",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginState.initialState());

        final broadcastStream =
            Stream.value(NavigateLoginEvent()).asBroadcastStream();

        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        final routes = {
          '/counter': (context) => const FakeCounterPage(),
        };

        await widgetTester.pumpWidget(MaterialApp(
            routes: routes,
            home: ViewModelProvider<LoginViewModel>(
              create: (context) => viewModel,
              child: const LoginPage(),
            )));

        await widgetTester.pumpAndSettle();

        expect(find.byType(FakeCounterPage), findsOneWidget);
      });
    });
  });
}

class FakeCounterPage extends StatelessWidget {
  const FakeCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
