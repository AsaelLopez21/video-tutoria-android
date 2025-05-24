import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_android_videollamada/call_controllers/call_controller.dart';
import 'package:proyecto_android_videollamada/screens/videocall.dart';

Future<void> answerCall(String callId, BuildContext context) async {
  final callDoc = FirebaseFirestore.instance.collection('calls').doc(callId);
  final callDataSnapshot = await callDoc.get();
  final callData = callDataSnapshot.data();
  print('SE ESTA RECIBIENDO UNA LLAMADA ID LLAMADA: $callId');

  if (!context.mounted) {
    print('CONTEXTO NO MONTADO NO SE PUEDE NAVEGAR');
    return;
  } else {
    print('SI SE PUEDE NAVEGAR');
  }

  if (callData == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La llamada ya no está disponible')),
      );
    }
    return;
  }

  final offer = callData['offer'];

  final callController = CallController();

  final configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  callController.peerConnection = await createPeerConnection(configuration);

  await callController.localRenderer.initialize();
  await callController.remoteRenderer.initialize();

  final localStream = await navigator.mediaDevices.getUserMedia({
    'video': true,
    'audio': true,
  });
  callController.localRenderer.srcObject = localStream;

  localStream.getTracks().forEach((track) {
    callController.peerConnection!.addTrack(track, localStream);
  });

  callController.peerConnection!.onTrack = (event) {
    if (event.streams.isNotEmpty) {
      callController.remoteRenderer.srcObject = event.streams[0];
    }
  };

  callController.peerConnection!.onIceCandidate = (candidate) {
    callDoc.collection('calleeCandidates').add(candidate.toMap());
  };

  final offerDesc = RTCSessionDescription(offer['sdp'], offer['type']);
  await callController.peerConnection!.setRemoteDescription(offerDesc);

  final answer = await callController.peerConnection!.createAnswer();
  await callController.peerConnection!.setLocalDescription(answer);

  await callDoc.update({'answer': answer.toMap()});

  callDoc.collection('callerCandidates').snapshots().listen((snapshot) {
    for (var docChange in snapshot.docChanges) {
      if (docChange.type == DocumentChangeType.added) {
        final data = docChange.doc.data();
        callController.peerConnection!.addCandidate(
          RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          ),
        );
      }
    }
  });

  if (!context.mounted) return;

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
}
