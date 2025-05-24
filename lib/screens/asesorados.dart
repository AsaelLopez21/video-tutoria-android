import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/screens/videocall.dart';
import 'package:proyecto_android_videollamada/call_controllers/call_controller.dart';
import '../themes/app_colors.dart';

class AsesoradosScreen extends StatelessWidget {
  const AsesoradosScreen({Key? key}) : super(key: key);

  void _mostrarDialogoAgregar(BuildContext context) {
    final matriculaController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.whitte,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Buscar estudiante por matrícula',
                style: TextStyle(color: AppColors.darkBlue),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: matriculaController,
                    decoration: const InputDecoration(labelText: 'Matrícula'),
                    keyboardType: TextInputType.number,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.lightBlue),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final matricula = matriculaController.text.trim();

                    if (matricula.isEmpty || int.tryParse(matricula) == null) {
                      setState(() {
                        errorMessage = 'Ingresa una matrícula válida';
                      });
                      return;
                    }

                    final alumnoQuery =
                        await FirebaseFirestore.instance
                            .collection('usuarios')
                            .where('matricula', isEqualTo: matricula)
                            .get();

                    if (alumnoQuery.docs.isEmpty) {
                      setState(() {
                        errorMessage =
                            'No se encontró un estudiante con esa matrícula';
                      });
                      Timer(const Duration(seconds: 2), () {
                        setState(() {
                          errorMessage = null;
                        });
                      });
                      return;
                    }

                    final alumnoDoc = alumnoQuery.docs.first;
                    final alumnoData = alumnoDoc.data();
                    final alumnoUid = alumnoDoc.id;

                    final shouldAdd = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Agregar estudiante'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nombre: ${alumnoData['nombre'] ?? ''}'),
                                Text('Correo: ${alumnoData['email'] ?? ''}'),
                                Text(
                                  'Teléfono: ${alumnoData['telefono'] ?? ''}',
                                ),
                                Text(
                                  'Matrícula: ${alumnoData['matricula'] ?? ''}',
                                ),
                                const SizedBox(height: 16),
                                const Text('¿Deseas agregar este estudiante?'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Agregar'),
                              ),
                            ],
                          ),
                    );

                    if (shouldAdd != true) return;

                    final uid = FirebaseAuth.instance.currentUser!.uid;

                    final docRef = FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(uid)
                        .collection('contactos')
                        .doc(alumnoUid);

                    await docRef.set({
                      'nombre': alumnoData['nombre'] ?? '',
                      'telefono': alumnoData['telefono'] ?? '',
                      'correo': alumnoData['correo'] ?? '',
                      'matricula': alumnoData['matricula'] ?? '',
                    });

                    await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(alumnoUid)
                        .update({'tutorId': uid});

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Estudiante agregado correctamente'),
                      ),
                    );
                  },
                  child: const Text(
                    'Buscar y agregar',
                    style: TextStyle(color: AppColors.lightViolet),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _eliminarEstudiante(BuildContext context, String contactId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar estudiante'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este estudiante?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('contactos')
        .doc(contactId)
        .delete();

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(contactId)
        .update({'tutorId': FieldValue.delete()});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .collection('contactos')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error al cargar estudiantes'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final contactos = snapshot.data!.docs;

                    if (contactos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes estudiantes agregados',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: contactos.length,
                      itemBuilder: (context, index) {
                        final contacto = contactos[index];
                        final data = contacto.data() as Map<String, dynamic>;

                        return Card(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            title: Text(
                              data['nombre'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['telefono'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  data['matricula'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final calleeId = contacto.id;
                                    final callController = CallController();
                                    final callId = await callController
                                        .startCall(calleeId);
                                    if (callId != null) {
                                      Navigator.push(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => VideoCallScreen(
                                                callId: callId,
                                                isCaller: true,
                                                callController: callController,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed:
                                      () => _eliminarEstudiante(
                                        context,
                                        contacto.id,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAgregar(context),
        backgroundColor: AppColors.lightViolet,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }
}
