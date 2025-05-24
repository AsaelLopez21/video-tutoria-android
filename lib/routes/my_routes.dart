import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/widgets/screens_imports.dart';

class MyRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'calendar': (context) => const CalendarScreen(),
      'asesorados': (context) => const AsesoradosScreen(),
      'anunciosProfesor': (context) => const Anunciosprofesor(),
      'anunciosAlumno': (context) => const AnunciosAlumno(),
      'tutor': (context) => const TutorScreen(),

      'home': (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        if (args == null) {
          return const LoginScreen();
        }

        return HomeScreen(
          email: args['email'] as String? ?? '',
          role: args['role'] as String? ?? 'sin rol',
          matricula: args['matricula'] as String?,
          nombre: args['nombre'] as String? ?? 'Usuario',
        );
      },
    };
  }
}
