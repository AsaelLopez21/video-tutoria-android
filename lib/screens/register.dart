import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../themes/app_colors.dart';
import '../widgets/custom_text.dart';
import '../widgets/role_selector.dart';
import '../widgets/login_redirect.dart';
import '../widgets/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedRole;
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/nova.png'),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _RegisterCard(
                  password: password,
                  email: email,
                  selectedRole: selectedRole,
                  onpasswordChanged: (v) => setState(() => password = v),
                  onEmailChanged: (v) => setState(() => email = v),
                  onRoleSelected: (role) => setState(() => selectedRole = role),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final String password;
  final String email;
  final String? selectedRole;
  final ValueChanged<String> onpasswordChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onRoleSelected;

  const _RegisterCard({
    required this.password,
    required this.email,
    required this.selectedRole,
    required this.onpasswordChanged,
    required this.onEmailChanged,
    required this.onRoleSelected,
  });

  Future<void> createUser(BuildContext context) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty && selectedRole != null) {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = userCredential.user?.uid;

        if (uid != null) {
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
            'email': email,
            'rol': selectedRole,
            'createdAt': Timestamp.now(),
          });

          if (context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              'home', // ← asegúrate de tener esta ruta en MyRoutes
              arguments: {'email': email, 'role': selectedRole!},
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, completa todos los campos.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'El correo ya está en uso.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo no es válido.';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil.';
          break;
        default:
          errorMessage = 'Ocurrió un error inesperado: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        color: const Color.fromARGB(35, 0, 187, 255),
        backgroundBlendMode: BlendMode.overlay,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Video Tutoría\nRegistro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomTextField(hintText: 'Correo', onChanged: onEmailChanged),
          const SizedBox(height: 32),
          CustomStyledPasswordField(onChanged: onpasswordChanged),
          const SizedBox(height: 20),
          const Text(
            'Selecciona tu puesto',
            style: TextStyle(
              color: AppColors.whitte,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          RoleSelector(
            selectedRole: selectedRole,
            onRoleSelected: onRoleSelected,
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await createUser(context);
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
                'Registrarse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const LoginRedirect(),
        ],
      ),
    );
  }
}
