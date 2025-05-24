import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallController {
  //!instancia del profesor
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  Future<String?> startCall(String calleeId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    //y => descubrir las IP, ICE servidores para negociar la conexion
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, //y => servidor para pruebas
      ],
    };

    //!conexion de los dispositivos
    peerConnection = await createPeerConnection(configuration);

    await localRenderer.initialize();
    await remoteRenderer.initialize();

    //y => solicitar accesos a camara y microfono
    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });

    //Y => mostrar audio y video
    localRenderer.srcObject = _localStream;

    //y => agregar pistas de audio y video
    _localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, _localStream!);
    });

    //Y => Escuchar stream remoto
    peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    //y => crear documento de llamada en firestore
    final callDoc = _firestore.collection('calls').doc();
    final callId = callDoc.id;

    //y => buscar candidatos para la conexion
    peerConnection!.onIceCandidate = (candidate) {
      callDoc.collection('callerCandidates').add(candidate.toMap());
    };

    //y =>oferta SDP, proponer como sera la conexion, peer desea conectarse
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    //info => guardar oferta en firestore
    await callDoc.set({
      'callerId': user.uid,
      'calleeId': calleeId,
      'offer': offer.toMap(), //p => para poder guardarlo en firestore
      'createdAt': FieldValue.serverTimestamp(), //p => guardar tiempo actual
    });

    //y => escuchar la respuesta en firestore, si hay respuesta hacer que WebRTC escuche
    callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data == null || data['answer'] == null) return;
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      await peerConnection!.setRemoteDescription(answer);
    });

    //y => escuchar candidatos del estudiante
    callDoc.collection('calleCandidates').snapshots().listen((snapshot) {
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

  //y => terminar la llamada
  Future<void> endCall(String callId) async {
    // ! en firestore
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    await peerConnection?.close();
    await localRenderer.dispose();
    await remoteRenderer.dispose();

    //! eliminar candidatos y documentos
    for (final sub in ['callerCandidates', 'calleeCandidates']) {
      final snap =
          await FirebaseFirestore.instance
              .collection('calls')
              .doc(callId)
              .collection(sub)
              .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
    await FirebaseFirestore.instance.collection('calls').doc(callId).delete();
  }
}
