import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  StreamSubscription<DocumentSnapshot>? callSubscription;
  StreamSubscription<QuerySnapshot>? iceCandidatesSubscription;

  bool _isDisposed = false;

  Future<void> initializeRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  //y => Inicia una llamada
  Future<String?> startCall(String calleeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    peerConnection = await createPeerConnection(configuration);

    final callDoc = _firestore.collection('calls').doc();
    final callId = callDoc.id;

    //y => Configura onIceCandidate para enviar candidatos a firestore
    peerConnection!.onIceCandidate = (candidate) async {
      try {
        await callDoc.collection('callerCandidates').add(candidate.toMap());
      } catch (e) {
        debugPrint('Error enviando candidato ICE caller: $e');
      }
    };

    await initializeRenderers();

    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    localRenderer.srcObject = _localStream;

    _localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, _localStream!);
    });

    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    final offer = await peerConnection!.createOffer({'iceRestart': true});
    await peerConnection!.setLocalDescription(offer);

    await callDoc.set({
      'callerId': user.uid,
      'calleeId': calleeId,
      'offer': offer.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
    });

    //y => Escuchar respuesta del callee
    callSubscription = callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data == null || data['answer'] == null) return;

      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );

      try {
        await peerConnection!.setRemoteDescription(answer);
      } catch (e) {
        debugPrint('Error estableciendo descripción remota: $e');
      }
    });

    //y => escuchar candidatos ICE del callee
    iceCandidatesSubscription = callDoc
        .collection('calleeCandidates')
        .snapshots()
        .listen((snapshot) {
          for (var docChange in snapshot.docChanges) {
            if (docChange.type == DocumentChangeType.added) {
              final data = docChange.doc.data();
              if (data != null) {
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

  //y => Responde una llamada
  Future<void> answerCall(String callId) async {
    final callDoc = _firestore.collection('calls').doc(callId);
    final callDataSnapshot = await callDoc.get();
    final callData = callDataSnapshot.data();

    if (callData == null) {
      debugPrint('La llamada ya no está disponible');
      return;
    }

    final offer = callData['offer'];

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    peerConnection = await createPeerConnection(configuration);

    await initializeRenderers();

    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    localRenderer.srcObject = _localStream;

    _localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, _localStream!);
    });

    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    peerConnection!.onIceCandidate = (candidate) async {
      try {
        await callDoc.collection('calleeCandidates').add(candidate.toMap());
      } catch (e) {
        debugPrint('Error enviando candidato ICE callee: $e');
      }
    };

    final offerDesc = RTCSessionDescription(offer['sdp'], offer['type']);
    await peerConnection!.setRemoteDescription(offerDesc);

    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    await callDoc.update({'answer': answer.toMap()});

    //y => Escuchar candidatos ICE del caller
    iceCandidatesSubscription = callDoc
        .collection('callerCandidates')
        .snapshots()
        .listen((snapshot) {
          for (var docChange in snapshot.docChanges) {
            if (docChange.type == DocumentChangeType.added) {
              final data = docChange.doc.data();
              if (data != null) {
                peerConnection!.addCandidate(
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
  }

  //y => Termina la llamada y limpia recursos
  Future<void> endCallController(String callId) async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await iceCandidatesSubscription?.cancel();
      iceCandidatesSubscription = null;

      await callSubscription?.cancel();
      callSubscription = null;

      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream = null;

      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;

      await peerConnection?.close();
      peerConnection = null;

      await localRenderer.dispose();
      await remoteRenderer.dispose();

      final callDoc = _firestore.collection('calls').doc(callId);

      try {
        await callDoc.update({'active': false});
      } catch (e) {
        debugPrint(
          'No se pudo actualizar active: false, puede que el documento ya no exista.',
        );
      }

      await Future.delayed(const Duration(seconds: 1));

      for (final sub in ['callerCandidates', 'calleeCandidates']) {
        try {
          final snap = await callDoc.collection(sub).get();
          for (final doc in snap.docs) {
            await doc.reference.delete();
          }
        } catch (e) {
          debugPrint('Error eliminando candidatos $sub: $e');
        }
      }

      try {
        await callDoc.delete();
      } catch (e) {
        debugPrint('Error eliminando documento de llamada: $e');
      }
    } catch (e) {
      debugPrint('Error al finalizar la llamada: $e');
    }
  }
}
