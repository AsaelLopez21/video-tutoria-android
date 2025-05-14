import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/routes/my_routes.dart';
import 'package:proyecto_android_videollamada/screens/home.dart';
import './screens/register.dart';

//!firebase
import 'package:firebase_core/firebase_core.dart';
import './db/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: MyRoutes.getRoutes(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final user = snapshot.data;

          if (user != null) {
            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.uid)
                      .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;

                final role = data?['rol'] ?? 'sin rol';
                final email = user.email ?? '';

                return HomeScreen(email: email, role: role);
              },
            );
          }

          return const RegisterScreen();
        },
      ),
    );
  }
}
