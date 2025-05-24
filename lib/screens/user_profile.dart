import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/screens/register.dart';
import '../themes/app_colors.dart';

class UserProfileScreen extends StatelessWidget {
  final String? email;
  final String? role;
  final String? matricula;
  final String? nombre;

  const UserProfileScreen({
    Key? key,
    this.email,
    this.role,
    this.matricula,
    this.nombre,
  }) : super(key: key);

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
        child: Column(
          children: [
            const SizedBox(height: 60),
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/nova.png'),
            ),
            const SizedBox(height: 35),
            Flexible(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(35, 0, 187, 255),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Información de usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildDisplayField(nombre ?? 'No disponible'),

                      if (matricula != null && matricula!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDisplayField(matricula!),
                      ],

                      if (matricula == null || matricula?.isEmpty == true) ...[
                        const SizedBox(height: 16),
                        _buildDisplayField(email ?? 'No disponible'),
                      ],
                      const SizedBox(height: 12),
                      _buildDisplayField(role ?? 'No disponible'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightViolet,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayField(String value) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
        border: Border.all(color: const Color(0xFFB0B0B0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
