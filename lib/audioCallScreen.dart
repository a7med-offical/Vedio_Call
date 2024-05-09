import "package:agora_rtc_engine/rtc_engine.dart";
import "package:flutter/material.dart";
import "package:flutter_application_1/appBrain.dart";
import "package:permission_handler/permission_handler.dart";

class AudioCallScreen extends StatefulWidget {
const AudioCallScreen({Key? key}) : super(key: key);

@override
_AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
late int _remoteUid = 0;
late RtcEngine _engine;

@override
void initState() {
super.initState();
initAgora();
}

@override
void dispose() {
super.dispose();
_engine.leaveChannel();
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
children: [
Container(
color: Colors.black87,
child: Center(
child: _remoteUid == 0
? const Text(
"Calling …",
style: TextStyle(color: Colors.white),
)
: Text(
"Calling with $_remoteUid",
),
),
),
Align(
alignment: Alignment.bottomCenter,
child: Padding(
padding: const EdgeInsets.only(bottom: 25.0, right: 25),
child: Container(
height: 50,
color: Colors.black12,
child: Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
IconButton(
onPressed: () {
Navigator.of(context).pop(true);
},
icon: const Icon(
Icons.call_end,
size: 44,
color: Colors.redAccent,
)),
],
),
),
),
),
],
),
);
}

Future<void> initAgora() async {
await [Permission.microphone, Permission.camera].request();
_engine = await RtcEngine.create(AgoraManager.appId);
_engine.enableVideo();
_engine.setEventHandler(
RtcEngineEventHandler(
joinChannelSuccess: (String channel, int uid, int elapsed) {
print("local user $uid joined successfully");
},
userJoined: (int uid, int elapsed) {
print("remote user $uid joined successfully");
setState(() => _remoteUid = uid);
},
userOffline: (int uid, UserOfflineReason reason) {
print("remote user $uid left call");
setState(() => _remoteUid = 0);
Navigator.of(context).pop(true);
},
),
);
await _engine.joinChannel(
AgoraManager.token, AgoraManager.channelName, null, 0);
}

Widget _renderRemoteAudio() {
if (_remoteUid != 0) {
return Text(
"Calling with $_remoteUid",
style: const TextStyle(color: Colors.white),
);
} else {
return const Text(
"Calling …",
style: TextStyle(color: Colors.white),
);
}
}
}