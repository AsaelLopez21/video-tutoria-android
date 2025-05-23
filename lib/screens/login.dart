import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/screens/home.dart';
import '../widgets/password_field.dart';
import 'package:proyecto_android_videollamada/widgets/register_redirect.dart';
import '../themes/app_colors.dart';
import '../widgets/custom_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String password = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ), // Reduced spacing
                const CircleAvatar(
                  radius: 40, // Reduced size
                  backgroundImage: AssetImage('assets/images/nova.png'),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ), // Reduced spacing
                _LoginCard(
                  email: email,
                  password: password,
                  onEmailChanged: (v) => setState(() => email = v),
                  onPasswordChanged: (v) => setState(() => password = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final String email;
  final String password;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;

  const _LoginCard({
    required this.email,
    required this.password,
    required this.onEmailChanged,
    required this.onPasswordChanged,
  });
  Future<Map<String, dynamic>?> loginUser(BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .get();

        final data = doc.data();
        final role = data?['rol'] ?? 'sin rol';
        final userEmail = user.email ?? '';
        final matricula = data?['matricula'] as String?;
        final nombre = data?['nombre'] as String? ?? 'Nombre no disponible';

        return {
          'email': userEmail,
          'role': role,
          'matricula': matricula,
          'nombre': nombre,
        };
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No existe un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else {
        message = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.')),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Reduced border radius
        border: Border.all(color: Colors.white),
        color: const Color.fromARGB(35, 0, 187, 255),
        backgroundBlendMode: BlendMode.overlay,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(51), // Equivalent to 20% opacity
            blurRadius: 30, // Reduced blur radius
            spreadRadius: 1, // Reduced spread radius
            offset: const Offset(0, 3), // Reduced offset
          ),
        ],
      ),
      padding: const EdgeInsets.all(16), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Video Tutoría\nLogin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Reduced font size
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // Reduced spacing
          CustomTextField(
            hintText: 'Correo',
            isCompact: true,

            onChanged: onEmailChanged,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32), // Reduced spacing
          CustomStyledPasswordField(
            onChanged: onPasswordChanged,
            isCompact: true,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) =>
                          const Center(child: CircularProgressIndicator()),
                );

                final userData = await loginUser(context);

                if (Navigator.of(context).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }

                if (userData != null && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => HomeScreen(
                            email: userData['email'],
                            role: userData['role'],
                            matricula: userData['matricula'],
                            nombre: userData['nombre'],
                          ),
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightViolet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          const RegisterRedirect(),
        ],
      ),
    );
  }
}
