import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class AnunciosAlumno extends StatefulWidget {
  const AnunciosAlumno({super.key});

  @override
  State<AnunciosAlumno> createState() => _AnunciosAlumnoState();
}

class _AnunciosAlumnoState extends State<AnunciosAlumno> {
  Map<String, dynamic>? tutorData;
  bool isLoading = true;
  String? tutorId;

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
      tutorId = alumnoData['tutorId'] as String;
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

  Widget _buildAnuncioItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['titulo'] ?? 'Sin título',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['contenido'] ?? 'Sin contenido',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(data['fecha']),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Fecha desconocida';
    final date = (timestamp as Timestamp).toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Anuncios del Tutor',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('usuarios')
                                        .doc(tutorId)
                                        .collection('notas')
                                        .orderBy('fecha', descending: true)
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                        'Error al cargar anuncios',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final docs = snapshot.data?.docs ?? [];
                                  if (docs.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No hay anuncios disponibles',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      final data =
                                          docs[index].data()!
                                              as Map<String, dynamic>;
                                      return _buildAnuncioItem(data);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
