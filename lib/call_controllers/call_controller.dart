import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  //y => Suscripcion para candidatos ICE del otro peer
  StreamSubscription? iceCandidatesSubscription;
  StreamSubscription? callSubscription;

  Future<String?> startCall(String calleeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    //y => debugPrint('Creando RTCPeerConnection para caller');
    peerConnection = await createPeerConnection(configuration);

    //y => Crear documento de llamada en Firestore
    final callDoc = _firestore.collection('calls').doc();
    final callId = callDoc.id;
    //y => debugPrint('Documento de llamada creado');

    //y => Asignar onIceCandidate ANTES de crear la oferta para capturar todos los candidatos
    peerConnection!.onIceCandidate = (candidate) async {
      //y => debugPrint('Caller: Enviando candidato ICE');
      try {
        await callDoc.collection('callerCandidates').add(candidate.toMap());
        //y => debugPrint('Caller: Candidato ICE enviado correctamente');
      } catch (e) {
        //y => debugPrint('Error enviando candidato ICE caller');
      }
    };

    await localRenderer.initialize();
    await remoteRenderer.initialize();

    //y => debugPrint('Obteniendo stream local');
    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    localRenderer.srcObject = _localStream;

    _localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, _localStream!);
      //y => debugPrint('Caller: Track agregado');
    });

    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
        //y => debugPrint('Caller: Recibiendo stream remoto');
      }
    };

    //y => debugPrint('Creando oferta con iceRestart');
    final offer = await peerConnection!.createOffer({'iceRestart': true});
    await peerConnection!.setLocalDescription(offer);
    //y => debugPrint('Oferta creada y establecida');

    //y => ringing
    await callDoc.set({
      'callerId': user.uid,
      'calleeId': calleeId,
      'offer': offer.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'ringing',
    });
    //y => debugPrint('Oferta guardada en Firestore');

    //y => escuchar respuesta del callee
    callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data == null || data['answer'] == null) return;
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      //y => debugPrint('Caller: Recibiendo respuesta');
      if (peerConnection != null) {
        await peerConnection!.setRemoteDescription(answer);
      } else {
        debugPrint('peerConnection no esta inicializado');
      }
      //y => debugPrint('Caller: Respuesta establecida remotamente');
    });

    //! Escuchar candidatos ICE del callee
    iceCandidatesSubscription = callDoc
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {
          for (var docChange in snapshot.docChanges) {
            if (docChange.type == DocumentChangeType.added) {
              final data = docChange.doc.data();
              if (data != null) {
                //y => debugPrint('Caller: Recibiendo candidato ICE del callee',);
                peerConnection!.addCandidate(
                  RTCIceCandidate(
                    data['candidate'] ?? '',
                    data['sdpMid'] ?? '',
                    data['sdpMLineIndex'] ?? 0,
                  ),
                );
              }
            }
          }
        });

    return callId;
  }

  Future<void> endCallController(String callId) async {
    try {
      //y => referencia al documento de llamada
      final callDoc = _firestore.collection('calls').doc(callId);
      await callDoc.update({'status': 'ended'});

      //y => eliminar subcolecciones
      for (final subcollection in ['callerCandidates', 'calleeCandidates']) {
        final snapshot = await callDoc.collection(subcollection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      //y => eliminar documento principal para notificar fin de llamada
      await callDoc.delete();

      //y => debugPrint('Llamada eliminada correctamente');

      //o => ancelar suscripciones
      await iceCandidatesSubscription?.cancel();
      iceCandidatesSubscription = null;
      await callSubscription?.cancel();
      callSubscription = null;

      //y => detener pistas del stream local
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream = null;

      //g => limpiar renderizadores
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;

      //g => cerrar peerConnection
      if (peerConnection != null) {
        await peerConnection!.close();
        peerConnection = null;
      }

      //o => disponer renderizadores
      await localRenderer.dispose();
      await remoteRenderer.dispose();
    } catch (e) {
      debugPrint('Error al finalizar la llamada: $e');
    }
  }
}
