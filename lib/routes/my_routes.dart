import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/screens/calendar.dart';
import 'package:proyecto_android_videollamada/screens/contacts.dart';
import 'package:proyecto_android_videollamada/screens/notes.dart';
import 'package:proyecto_android_videollamada/screens/register.dart';
import 'package:proyecto_android_videollamada/screens/login.dart';
import 'package:proyecto_android_videollamada/screens/home.dart'; 

class MyRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'calendar': (context) => const CalendarScreen(),
      'contacts': (context) => const ContactsScreen(),
      'notes': (context) => const NotesScreen(),
      
      'home': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HomeScreen(
          email: args['email'],
          role: args['role'],
        );
      },
    };
  }
}
