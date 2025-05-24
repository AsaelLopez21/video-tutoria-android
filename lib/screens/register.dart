import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../themes/app_colors.dart';
import 'package:proyecto_android_videollamada/widgets/widgets_import.dart';

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
  String nombre = '';
  String telefono = '';

  Future<void> createUser() async {
    try {
      if (email.isEmpty ||
          password.isEmpty ||
          selectedRole == null ||
          nombre.trim().isEmpty ||
          telefono.trim().isEmpty ||
          (selectedRole == 'Estudiante' && matricula.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, completa todos los campos.'),
          ),
        );
        return;
      }

      if (RegExp(r'[0-9]').hasMatch(nombre)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre no puede contener números.')),
        );
        return;
      }

      if (RegExp(r'[A-Za-z]').hasMatch(telefono)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El teléfono solo debe contener números.'),
          ),
        );
        return;
      }

      if (selectedRole == 'Estudiante') {
        final query =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .where('matricula', isEqualTo: matricula.trim())
                .get();

        if (query.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La matrícula ya está registrada.')),
          );
          return;
        }
      }
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        final userData = {
          'email': email,
          'rol': selectedRole,
          'nombre': nombre.trim(),
          'telefono': telefono.trim(),
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
          // ignore: use_build_context_synchronously
          Navigator.pop(context); // Quitar loading
          Navigator.pushReplacementNamed(
            // ignore: use_build_context_synchronously
            context,
            'home',
            arguments: {
              'email': email,
              'role': selectedRole!,
              'matricula': matricula,
              'nombre':nombre
            },
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      if (context.mounted) Navigator.pop(context);
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
                        'Video Tutoría Registro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                        hintText: 'Nombre',
                        keyboardType: TextInputType.name,
                        isCompact: true,
                        onChanged: (v) => setState(() => nombre = v),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'Teléfono',
                        keyboardType: TextInputType.phone,
                        isCompact: true,
                        onChanged: (v) => setState(() => telefono = v),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: 'Correo',
                        isCompact: true,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (v) => setState(() => email = v),
                      ),
                      const SizedBox(height: 12),
                      CustomStyledPasswordField(
                        onChanged: (v) => setState(() => password = v),
                        isCompact: true,
                      ),
                      if (selectedRole == 'Estudiante') ...[
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: 'Matrícula',
                          keyboardType: TextInputType.text,
                          isCompact: true,
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
