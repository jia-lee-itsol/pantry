import 'package:flutter/material.dart';

/// Loading Widget
///
/// A reusable loading indicator widget that displays a centered
/// circular progress indicator. Used throughout the application
/// to indicate loading states.
///
/// This widget is stateless and can be used anywhere a loading
/// state needs to be displayed.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

