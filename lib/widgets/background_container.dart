// widgets/background_container.dart
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final FloatingActionButton? floatingActionButton;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.floatingActionButton,  // Se agrega este parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que el fondo se mueva
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(child: child),
      ),
      floatingActionButton: floatingActionButton, // Aquí se pasa el fab
    );
  }
}
