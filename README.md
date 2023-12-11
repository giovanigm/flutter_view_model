# flutter_view_model

[![codecov](https://codecov.io/gh/giovanigm/flutter_view_model/graph/badge.svg?token=B9YX8Y0GYZ)](https://codecov.io/gh/giovanigm/flutter_view_model)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)

A MVVM Flutter State Management library based on [orbit-mvi](https://orbit-mvi.org/) and [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Motivation

## Usage

#### ViewModelBuilder

A widget that uses `States` emitted by the `ViewModel` to construct new widgets through the `builder` function.

If you also need to react to `Effects`, please see `ViewModelConsumer`.

```dart
ViewModelBuilder<MyViewModel, MyState>() {
  builder: (context, state) {
    return MyWidget();
  },
}
```

If `viewModel` is not provided, `ViewModelBuilder` will look up the widget tree using `ViewModelProvider` and the current `BuildContext` for a compatible ViewModel.

#### ViewModelListener

A Widget that reacts to `Effects` emitted by `ViewModel` and invokes `listener` callback.

It should be used when you only need to deal with side effects such as navigating after some validation, displaying feedback SnackBars, and similar cases.

If you also need to react to `States`, please see `ViewModelConsumer`.

```dart
ViewModelListener<MyViewModel, MyEffect>() {
  listener: (context, effect) {
    // do something
  },
  child: const SizedBox(),
}
```

If `viewModel` is not provided, `ViewModelListener` will look up the widget tree using `ViewModelProvider` and the current `BuildContext` for a compatible ViewModel.

#### ViewModelConsumer

A widget that uses both `States` and `Effects` emitted by the `ViewModel` to construct new widgets and react to effects.

If you need to react only either to `States` or `Effects`, see `ViewModelBuilder` and `ViewModelListener`.

```dart
ViewModelConsumer<MyViewModel, MyState, MyEffect>() {
  listener: (context, effect) {
    // do something
  },
  builder: (context, state) {
    return MyWidget();
  },
}
```

If `viewModel` is not provided, `ViewModelConsumer` will look up the widget tree using `ViewModelProvider` and the current `BuildContext` for a compatible ViewModel.

#### ViewModelProvider

Provides a `ViewModel` created through the `create` function to descendant widgets.

Widgets below in the tree can access the provided `ViewModel` through `ViewModelProvider.of(context)`.

```dart
ViewModelProvider<MyViewModel>() {
  create: (context) => MyViewModel(),
  child: const SizedBox(),
}
```

Automatically closes the created `ViewModel`. If you want to retain the ViewModel instance, use the `value` constructor.

The `ViewModel` instance will be created only when requested. For the opposite behavior, set `lazy = false`.

#### Context extensions

## Testing

#### ViewModel

#### Widgets

**ViewModelBuilder**

The `ViewModelBuilder` class is a widget that facilitates the reactive construction of widgets based on states emitted by a specified `ViewModel`. It is particularly useful for managing the state of Flutter applications in a clean and organized manner. The class is part of a state management package, and its primary purpose is to simplify the process of rebuilding widgets in response to changes in the underlying state.

### Example Usage:
```dart
ViewModelBuilder<MyViewModel, MyState>(
  builder: (context, state) {
    return MyWidget();
  },
)
```

If the viewModel isn't accessible via a parent `ViewModelProvider` and the current `BuildContext`, it is possible to define using viewModel parameter.

```dart
ViewModelBuilder<MyViewModel, MyState>(
  viewModel: myViewModel, // provide local viewModel instance
  builder: (context, state) {
    return MyWidget();
  }
)
```

For precise control over when the `builder` function is invoked, you have the option to include an optional parameter called `buildWhen`. This function takes both the previous and current states of the `ViewModel` and returns a boolean value. If `buildWhen` evaluates to true, the `builder` will be executed with the current state, triggering a widget rebuild. Conversely, if `buildWhen` returns false, the `builder` won't be invoked, and no rebuild will take place.

By utilizing the `buildWhen` parameter, you gain fine-grained control over the widget's rebuilding process, allowing you to make decisions based on changes in the underlying state of your `ViewModel`. This enhances flexibility and optimizes the performance of your Flutter application by selectively rebuilding widgets only when necessary.

```dart
ViewModelBuilder<MyViewModel, MyState>(
  buildWhen: (previousState, currentState) {
    // Specify conditions to determine whether or not
    // to rebuild the widget with the current state.
    // Return true to trigger a rebuild, or false otherwise.
  },
  builder: (context, state) {
    // Construct and return the widget based on MyViewModel's state.
  }
)
```

##### Mock ViewModel

##### Real ViewModel

## Contributing
