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

  const HomeScreen({Key? key, required this.email, required this.role})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obtener el tamaño de la pantalla
    return Scaffold(
      // resizeToAvoidBottomInset:
      //     false, // Permitimos el movimiento del contenido, no del fondo
      // PersistentBottomNavBar que permanece fijo en la parte inferior
      bottomNavigationBar: PersistentBottomNavBar(
        menuItems: [
          NavbarPages(
            titleMenu: "Inicio",
            icon: Icons.home,
            screen: UserProfileScreen(email: email, role: role),
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
