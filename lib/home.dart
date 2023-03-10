import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smsapp/controller/getx_controller.dart';
import 'package:smsapp/providers/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool _lights = false;
  String canal = "";
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  Future<void> _server(context) async {
    var provider = Provider.of<MyProvider>(context, listen: false);

    IO.Socket socket = IO.io(provider.myUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    if (_MyHomePageState._lights == true) {
      socket.connect();
      socket.onConnect((_) => print('connect')
          //socket.emit('message', 'test');
          );
      socket.on('$canal', (_) => initPlatformState(_));
    } else {
      socket.disconnect();
      socket.onDisconnect((_) => print('disconnect')
          //socket.emit('message', 'test');
          );
    }

    // socket.on('message', (_) => initPlatformState(_));
    // socket.on('connect', (_) => print('connect: ${socket.id}'));
    //socket.on('disconnect', (_) => print('disconnect'));
    //socket.on('fromServer', (_) => print(_));
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

  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var provider = Provider.of<MyProvider>(context, listen: false);
      setState(() {
        provider.url = 'http://198.251.68.200:3030';
      });
    });
    canal = "";
    super.initState();
  }

// getx
  CanalController _controller = CanalController();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyProvider>(context);
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
                _server(context);
              }),
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
                          readOnly: (_lights == true),
                          initialValue: provider.myUrl,
                          onChanged: (value) {
                            provider.url = value;

                            // setState(() {
                            //   provider.url = value;
                            // });
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
          ListTile(
            title: const Text('Canal'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text(
                          "Canal",
                        ),
                        content: TextFormField(
                          readOnly: (_lights == true),
                          initialValue: canal,
                          onChanged: (value) {
                            canal = value;

                            // setState(() {
                            //   provider.url = value;
                            // });
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
          Text(canal),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
