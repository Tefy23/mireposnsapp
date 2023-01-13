import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smsapp/providers/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _lights = false;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyProvider>(context);
    provider.url = 'http://198.251.68.245:3030';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Estado del servicio'),
            value: _lights,
            onChanged: (bool value) {
              setState(() {
                _lights = value;
              });
              if (_lights) {
                _server(context);
              } else {
                //  _server(context);
              }
            },
          ),
          ListTile(
            title: const Text('URL del servidor'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text(
                          "URL del Servidor",
                        ),
                        content: TextFormField(
                          initialValue: provider.myUrl,
                          onChanged: (value) {
                            provider.url = value;
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ));
            },
          ),
          Text(provider.myUrl),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<void> _server(context) async {
  var provider = Provider.of<MyProvider>(context, listen: false);

  IO.Socket socket = IO.io(provider.myUrl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  socket.connect();
  socket.onConnect((_) {
    print('connect');
    socket.emit('message', 'test');
  });
  socket.on('message', (_) => initPlatformState(_));
  socket.on('connect', (_) => print('connect: ${socket.id}'));
  socket.on('disconnect', (_) => print('disconnect'));
  socket.on('fromServer', (_) => print(_));

  socket.disconnect();
  socket.onDisconnect((_) {
    print('Disconnect');
  });
}

Future<void> initPlatformState(payload) async {
  final telephony = Telephony.instance;
  var val = payload.toString().split(",");

  final bool? result = await telephony.requestPhoneAndSmsPermissions;

  if (result != null && result) {
    try {
      telephony.sendSms(to: val[0], message: val[1]);
      print("se envio");
    } catch (e) {
      print(e.toString());
    }
  }
}
