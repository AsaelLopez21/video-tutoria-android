import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_android_videollamada/call_controllers/call_controller.dart';
import 'package:proyecto_android_videollamada/screens/videocall.dart';

Future<StreamSubscription> answerCall(
  String callId,
  BuildContext context, {
  required CallController callController,
}) async {
  final callDoc = FirebaseFirestore.instance.collection('calls').doc(callId);
  final callDataSnapshot = await callDoc.get();
  final callData = callDataSnapshot.data();
  // y=> debugPrint('SE ESTÁ RECIBIENDO UNA LLAMADA');

  if (!context.mounted) {
    //y => debugPrint('Contexto no montado, no se puede navegar.');
    return Stream.empty().listen((_) {});
  } else {
    debugPrint('Contexto montado, se puede navegar.');
  }

  if (callData == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La llamada ya no está disponible')),
      );
    }
    return Stream.empty().listen((_) {});
  }

  final offer = callData['offer'];

  final configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  //y => debugPrint('Creando RTCPeerConnection');
  callController.peerConnection = await createPeerConnection(configuration);

  await callController.localRenderer.initialize();
  await callController.remoteRenderer.initialize();

  //y => debugPrint('Obteniendo stream local');
  final localStream = await navigator.mediaDevices.getUserMedia({
    'video': true,
    'audio': true,
  });
  callController.localRenderer.srcObject = localStream;

  localStream.getTracks().forEach((track) {
    callController.peerConnection!.addTrack(track, localStream);
    //y => debugPrint('Callee: Track agregado}');
  });

  callController.peerConnection!.onTrack = (event) {
    if (event.streams.isNotEmpty) {
      callController.remoteRenderer.srcObject = event.streams[0];
      //y => debugPrint('Callee: Recibiendo stream remoto');
    }
  };

  callController.peerConnection!.onIceCandidate = (candidate) async {
    //y => debugPrint('Callee: Enviando candidato ICE');
    try {
      await callDoc.collection('calleeCandidates').add(candidate.toMap());
      //y => debugPrint('Callee: Candidato ICE enviado correctamente');
    } catch (e) {
      debugPrint('Error enviando candidato ICE callee');
    }
  };

  final offerDesc = RTCSessionDescription(offer['sdp'], offer['type']);
  //y => debugPrint('Estableciendo descripcion remota');
  await callController.peerConnection!.setRemoteDescription(offerDesc);
  //y => debugPrint('Descripcion remota establecida');

  //y => debugPrint('Creando y estableciendo respuesta');
  final answer = await callController.peerConnection!.createAnswer();
  await callController.peerConnection!.setLocalDescription(answer);

  await callDoc.update({'answer': answer.toMap(), 'status': 'answered'});
  //y => debugPrint('Respuesta guardada en Firestore');

  final callSubscription = callDoc
      .collection('callerCandidates')
      .snapshots()
      .listen((snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            final data = docChange.doc.data();
            if (data != null) {
              //y => debugPrint('Callee: Recibiendo candidato ICE del caller',);
              callController.peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                ),
              );
            }
          }
        }
      });

  if (!context.mounted) return callSubscription;

  //y => debugPrint('Navegando a la pantalla de videollamada');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => VideoCallScreen(
            callId: callId,
            isCaller: false,
            callController: callController,
          ),
    ),
  );

  return callSubscription;
}
