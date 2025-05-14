import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  void _mostrarDialogoAgregar(BuildContext context) {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final correoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whitte,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Agregar contacto',
            style: TextStyle(color: AppColors.darkBlue),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
              ],
            ),
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
                final nombre = nombreController.text.trim();
                final telefono = telefonoController.text.trim();
                final correo = correoController.text.trim();

                if (nombre.isNotEmpty &&
                    telefono.isNotEmpty &&
                    correo.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final docRef =
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .collection('contactos')
                          .doc();

                  await docRef.set({
                    'nombre': nombre,
                    'telefono': telefono,
                    'correo': correo,
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: AppColors.lightViolet),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    Map<String, dynamic> contactData,
    String contactId,
  ) {
    final nombreController = TextEditingController(text: contactData['nombre']);
    final telefonoController = TextEditingController(
      text: contactData['telefono'],
    );
    final correoController = TextEditingController(text: contactData['correo']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whitte,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Editar contacto',
            style: TextStyle(color: AppColors.darkBlue),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                TextField(
                  controller: correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('contactos')
                    .doc(contactId)
                    .delete();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.lightViolet),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('contactos')
                    .doc(contactId)
                    .update({
                      'nombre': nombreController.text,
                      'telefono': telefonoController.text,
                      'correo': correoController.text,
                    });
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: AppColors.lightBlue),
              ),
            ),
          ],
        );
      },
    );
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
                        child: Text('Error al cargar contactos'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final contactos = snapshot.data!.docs;

                    if (contactos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes contactos aún.',
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
                            title: GestureDetector(
                              onTap:
                                  () => _showEditDialog(
                                    context,
                                    data,
                                    contacto.id,
                                  ),
                              child: Text(
                                data['nombre'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['telefono'] ?? '',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  data['correo'] ?? '',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.call, color: Colors.white),
                              onPressed: () {},
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
