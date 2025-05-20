import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/models/navbar_pages.dart';
import 'package:proyecto_android_videollamada/screens/calendar.dart';
import 'package:proyecto_android_videollamada/screens/contacts.dart';
import 'package:proyecto_android_videollamada/screens/notes.dart';
import 'package:proyecto_android_videollamada/screens/user_profile.dart';
import 'package:proyecto_android_videollamada/widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  final String email;
  final String role;
  final String? matricula;

  const HomeScreen({
    Key? key,
    required this.email,
    required this.role,
    this.matricula,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PersistentBottomNavBar(
        menuItems: [
          NavbarPages(
            titleMenu: "Inicio",
            icon: Icons.home,
            screen: UserProfileScreen(
              email: email,
              role: role,
              matricula: matricula,
            ),
            route: '/home',
          ),
          NavbarPages(
            titleMenu: "Calendario",
            icon: Icons.calendar_today,
            screen: const CalendarScreen(),
            route: '/calendar',
          ),
          NavbarPages(
            titleMenu: "Contactos",
            icon: Icons.contacts,
            screen: const ContactsScreen(),
            route: '/contacts',
          ),
          NavbarPages(
            titleMenu: "Notas",
            icon: Icons.note,
            screen: const NotesScreen(),
            route: '/notes',
          ),
        ],
      ),
    );
  }
}
