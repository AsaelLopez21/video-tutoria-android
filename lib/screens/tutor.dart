import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  Map<String, dynamic>? tutorData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTutorData();
  }

  Future<void> _fetchTutorData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final alumnoDoc =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final alumnoData = alumnoDoc.data();

    if (alumnoData != null && alumnoData['tutorId'] != null) {
      final tutorId = alumnoData['tutorId'] as String;
      final tutorDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(tutorId)
              .get();
      setState(() {
        tutorData = tutorDoc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        tutorData = null;
        isLoading = false;
      });
    }
  }

  Widget _buildDisplayField(String label, String value) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/nova.png'),
            ),
            const SizedBox(height: 35),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(35, 0, 187, 255),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : tutorData == null
                        ? const Center(
                          child: Text(
                            'No tienes un tutor asignado',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Información del Tutor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              if (tutorData!['nombre'] != null)
                                _buildDisplayField(
                                  'Nombre',
                                  tutorData!['nombre'],
                                ),
                              if (tutorData!['email'] != null)
                                _buildDisplayField(
                                  'Correo',
                                  tutorData!['email'],
                                ),
                              // if (tutorData!['telefono'] != null)
                              //   _buildDisplayField(
                              //     'Teléfono',
                              //     tutorData!['telefono'],
                              //   ),
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
}
