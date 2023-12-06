import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'view_model.dart';

/// Provides a [ViewModel] created through the [create] function to descendant
/// widgets.
///
/// Widgets below in the tree can access the provided [ViewModel] through
/// `ViewModelProvider.of(context)`.
///
/// ```dart
/// ViewModelProvider<MyViewModel>() {
///   create: (context) => MyViewModel(),
///   child: const SizedBox(),
/// }
/// ```
///
/// Automatically closes the created [ViewModel]. If you want to retain the
/// ViewModel instance, use the [value] constructor.
///
/// The [ViewModel] instance will be created only when requested. For the
/// opposite behavior, set `lazy = false`.
class ViewModelProvider<T extends ViewModel<Object?, Object?>>
    extends SingleChildStatelessWidget {
  const ViewModelProvider({
    required Create<T> create,
    Key? key,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(key: key, child: child);

  /// Passes a previously created instance of [ViewModel] to the tree below.
  ///
  /// Does not automatically close the [ViewModel], but ensure that it is
  /// created by a [ViewModelProvider] higher in the tree using the [create]
  /// function so that it can be closed when no longer needed.
  const ViewModelProvider.value({
    required T value,
    Key? key,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = true,
        super(key: key, child: child);

  /// The child [Widget].
  final Widget? child;

  /// Controls wheter [create] will be called right away.
  ///
  /// The default value is `false`.
  final bool lazy;

  final Create<T>? _create;

  final T? _value;

  /// Function that allows descendant widgets of this [ViewModelProvider] to
  /// access the provided [ViewModel] using:
  ///
  /// ```dart
  /// ViewModelProvider.of<MyViewModel>(context);
  /// ```
  static T of<T extends ViewModel<Object?, Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        ViewModelProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to ViewModelProvider.of<$T>().

        This can happen if the context you used comes from a widget above the ViewModelProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final value = _value;
    return value != null
        ? InheritedProvider<T>.value(
            value: value,
            startListening: _startListening,
            lazy: lazy,
            child: child,
          )
        : InheritedProvider<T>(
            create: _create,
            dispose: (_, viewModel) => viewModel.close(),
            startListening: _startListening,
            lazy: lazy,
            child: child,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<ViewModel<dynamic, dynamic>?> e,
    ViewModel<dynamic, dynamic> value,
  ) {
    final subscription = value.stateStream.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}
