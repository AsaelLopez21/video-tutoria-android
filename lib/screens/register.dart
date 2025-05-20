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
  String matricula = '';

  Future<void> createUser() async {
    try {
      if (email.isEmpty ||
          password.isEmpty ||
          selectedRole == null ||
          (selectedRole == 'Estudiante' && matricula.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, completa todos los campos.'),
          ),
        );
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        final userData = {
          'email': email,
          'rol': selectedRole,
          'createdAt': Timestamp.now(),
        };

        if (selectedRole == 'Estudiante') {
          userData['matricula'] = matricula.trim();
        }

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .set(userData);

        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            'home',
            arguments: {'email': email, 'role': selectedRole!,'matricula':matricula},
          );
        }
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
                Container(
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
                        onRoleSelected:
                            (role) => setState(() => selectedRole = role),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'Correo',
                        onChanged: (v) => setState(() => email = v),
                      ),
                      const SizedBox(height: 12),
                      CustomStyledPasswordField(
                        onChanged: (v) => setState(() => password = v),
                      ),
                      if (selectedRole == 'Estudiante') ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: 'Matrícula',
                          onChanged: (v) => setState(() => matricula = v),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await createUser();
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
