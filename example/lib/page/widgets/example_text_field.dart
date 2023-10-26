import 'package:flutter/material.dart';

class ExampleTextField extends StatelessWidget {
  const ExampleTextField({
    super.key,
    this.hintText = '',
    this.obscureText = false,
    this.onChanged,
  });

  final String hintText;
  final bool obscureText;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.start,
      obscureText: obscureText,
      onChanged: onChanged,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        hintText: hintText,
        hintStyle: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onBackground),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }
}
