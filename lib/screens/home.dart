import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/widgets/screens_imports.dart';
import 'package:proyecto_android_videollamada/models/navbar_pages.dart';
import 'package:proyecto_android_videollamada/widgets/bottom_navbar.dart';
import 'dart:async';
import 'package:proyecto_android_videollamada/call_controllers/answer_call.dart';

class HomeScreen extends StatefulWidget {
  final String? email;
  final String role;
  final String? matricula;
  final String? nombre;

  const HomeScreen({
    Key? key,
    this.email,
    required this.role,
    this.matricula,
    this.nombre,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? callSubscription;
  bool _isDialogShowing = false;

  //y => escuchar si el el usuario es estudiante
  @override
  void initState() {
    super.initState();
    if (widget.role == 'Estudiante') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        listenIncomingCalls(user.uid, context);
      }
    }
  }

  @override
  void dispose() {
    callSubscription?.cancel();
    super.dispose();
  }

  //y => escuchar la llamada
  void listenIncomingCalls(String studentUid, BuildContext context) {
    callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('calleeId', isEqualTo: studentUid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty && !_isDialogShowing) {
            final callDoc = snapshot.docs.first;
            _isDialogShowing = true;
            _showIncomingCallDialog(context, callDoc.id).then((_) {
              _isDialogShowing = false;
            });
          }
        });
  }

  //Y => mostrar dialogo de la llamada
  Future<void> _showIncomingCallDialog(
    BuildContext mainContext,
    String callId,
  ) {
    return showDialog(
      context: mainContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Llamada entrante'),
          content: const Text(
            'El profesor te está llamando. ¿Quieres contestar?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('calls')
                    .doc(callId)
                    .delete();
                Navigator.pop(dialogContext);
              },
              child: const Text('Rechazar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await callSubscription?.cancel();
                callSubscription = null;
                await answerCall(callId, mainContext);
              },
              child: const Text('Contestar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'Profesor') {
      return Scaffold(
        bottomNavigationBar: PersistentBottomNavBar(
          menuItems: [
            NavbarPages(
              titleMenu: "Inicio",
              icon: Icons.home,
              screen: UserProfileScreen(
                email: widget.email,
                role: widget.role,
                matricula: widget.matricula,
                nombre: widget.nombre,
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
              titleMenu: "Asesorados",
              icon: Icons.contacts,
              screen: const AsesoradosScreen(),
              route: '/asesorados',
            ),
            NavbarPages(
              titleMenu: "Anuncios",
              icon: Icons.note,
              screen: const Anunciosprofesor(),
              route: '/anunciosProfesor',
            ),
          ],
        ),
      );
    } else if (widget.role == 'Estudiante') {
      return Scaffold(
        bottomNavigationBar: PersistentBottomNavBar(
          menuItems: [
            NavbarPages(
              titleMenu: "Inicio",
              icon: Icons.home,
              screen: UserProfileScreen(
                email: widget.email,
                role: widget.role,
                matricula: widget.matricula,
                nombre: widget.nombre,
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
              titleMenu: "Tutor",
              icon: Icons.contacts,
              screen: const TutorScreen(),
              route: '/tutor',
            ),
            NavbarPages(
              titleMenu: "Anuncios",
              icon: Icons.note,
              screen: const AnunciosAlumno(),
              route: '/anunciosAlumno',
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        bottomNavigationBar: PersistentBottomNavBar(
          menuItems: [
            NavbarPages(
              titleMenu: "Inicio",
              icon: Icons.home,
              screen: UserProfileScreen(
                email: widget.email,
                role: widget.role,
                matricula: widget.matricula,
                nombre: widget.nombre,
              ),
              route: '/home',
            ),
          ],
        ),
      );
    }
  }
}
