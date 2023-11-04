import 'package:example/pages/examples/login/login_page.dart';
import 'package:example/pages/examples/login/login_page_event.dart';
import 'package:example/pages/examples/login/login_page_state.dart';
import 'package:example/pages/examples/login/login_page_view_model.dart';
import 'package:example/pages/widgets/example_text_field.dart';
import 'package:example/pages/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:view_model/view_model.dart';

import 'login_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<LoginPageViewModel>()])
void main() {
  group("Login Page", () {
    group('Mock ViewModel', () {
      late LoginPageViewModel viewModel;

      setUp(() {
        viewModel = MockLoginPageViewModel();
      });

      testWidgets("Should render initial state correctly",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginPageState.initialState());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
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
            .thenReturn(LoginPageState.initialState().invalidEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
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

      testWidgets("Should render invalid password state correctly",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginPageState.initialState().invalidPassword());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
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

      testWidgets(
          "Should disable button if email is valid and password is invalid",
          (widgetTester) async {
        when(viewModel.state)
            .thenReturn(LoginPageState.initialState().validEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
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
            .thenReturn(LoginPageState.initialState().validPassword());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
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
        when(viewModel.state).thenReturn(
            LoginPageState.initialState().validPassword().validEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
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
        when(viewModel.state).thenReturn(
            LoginPageState.initialState().validPassword().validEmail());

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        await widgetTester.tap(find.byType(FilledButton));

        verify(viewModel.login());
      });

      testWidgets("Should show loading on startLoadingEvent",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginPageState.initialState());

        final broadcastStream =
            Stream.value(LoadingLoginEvent.start()).asBroadcastStream();
        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        await widgetTester.pumpWidget(MaterialApp(
            builder: (context, child) => LoadingOverlay(child: child!),
            home: ViewModelProvider<LoginPageViewModel>(
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
        when(viewModel.state).thenReturn(LoginPageState.initialState());

        final broadcastStream =
            Stream.value(LoadingLoginEvent.stop()).asBroadcastStream();

        when(viewModel.lastEvent).thenReturn(LoadingLoginEvent.start());
        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        await widgetTester.pumpWidget(MaterialApp(
            builder: (context, child) => LoadingOverlay(child: child!),
            home: ViewModelProvider<LoginPageViewModel>(
              create: (context) => viewModel,
              child: const LoginPage(),
            )));

        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets("Should show snackbar on AuthenticationErrorLoginEvent",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginPageState.initialState());
        const message = "message";
        final broadcastStream =
            Stream.value(AuthenticationErrorLoginEvent(message))
                .asBroadcastStream();
        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        await widgetTester.pumpWidget(MaterialApp(
            builder: (context, child) => LoadingOverlay(child: child!),
            home: ViewModelProvider<LoginPageViewModel>(
              create: (context) => viewModel,
              child: const LoginPage(),
            )));

        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));

        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets("Should show success SnackBar on authenticated",
          (widgetTester) async {
        when(viewModel.state).thenReturn(LoginPageState.initialState());

        final broadcastStream =
            Stream.value(AuthenticatedLoginEvent()).asBroadcastStream();

        when(viewModel.eventStream).thenAnswer(
          (_) => broadcastStream.map((event) {
            when(viewModel.lastEvent).thenReturn(event);
            return event;
          }),
        );

        await widgetTester.pumpWidget(MaterialApp(
            home: ViewModelProvider<LoginPageViewModel>(
          create: (context) => viewModel,
          child: const LoginPage(),
        )));

        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));
        await widgetTester.pump(const Duration(seconds: 1));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text("User Authenticated!"), findsOneWidget);
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
