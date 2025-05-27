import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../themes/app_colors.dart';
import 'package:proyecto_android_videollamada/call_controllers/call_controller.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final bool isCaller;
  final CallController callController;

  // Constructor
  const VideoCallScreen({
    Key? key,
    required this.callId,
    required this.isCaller,
    required this.callController,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool micEnabled = true;
  bool camEnabled = true;

  @override
  void dispose() {
    widget.callController.localRenderer.dispose();
    widget.callController.remoteRenderer.dispose();
    widget.callController.peerConnection?.close();
    super.dispose();
  }

  void toggleMic() {
    setState(() {
      micEnabled = !micEnabled;
      widget.callController.localRenderer.srcObject?.getAudioTracks().forEach((
        track,
      ) {
        track.enabled = micEnabled;
      });
    });
  }

  void toggleCam() {
    setState(() {
      camEnabled = !camEnabled;
      widget.callController.localRenderer.srcObject?.getVideoTracks().forEach((
        track,
      ) {
        track.enabled = camEnabled;
      });
    });
  }

  void hangUp() async {
    try {
      await widget.callController.endCallController(widget.callId);
    } catch (e) {
      debugPrint('Error al finalizar la llamada: $e');
    }
    if (!mounted) return;
    Navigator.pop(context);
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
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ), // borde blanco del container principal
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ), // borde blanco en el video remoto
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: RTCVideoView(
                            widget.callController.remoteRenderer,
                            objectFit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      right: 16,
                      width: 120,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: RTCVideoView(
                            widget.callController.localRenderer,
                            mirror: true,
                            objectFit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag: 'mic',
                            backgroundColor:
                                micEnabled
                                    ? AppColors.lightBlue
                                    : Colors.redAccent,
                            onPressed: toggleMic,
                            child: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                          ),
                          FloatingActionButton(
                            heroTag: 'hangup',
                            backgroundColor: Colors.red,
                            onPressed: hangUp,
                            child: const Icon(Icons.call_end),
                          ),
                          FloatingActionButton(
                            heroTag: 'cam',
                            backgroundColor:
                                camEnabled
                                    ? AppColors.lightBlue
                                    : Colors.redAccent,
                            onPressed: toggleCam,
                            child: Icon(
                              camEnabled ? Icons.videocam : Icons.videocam_off,
                            ),
                          ),
                        ],
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
