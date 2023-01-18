import 'package:flutter/material.dart';
import 'package:smsapp/home.dart';
import 'package:provider/provider.dart';
import 'package:smsapp/providers/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyProvider>(
        create: (context) => MyProvider(),
        child: Consumer<MyProvider>(
            builder: (context, myProvider, child) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Cigar Key',
                  theme: ThemeData(
                    primarySwatch: Colors.yellow,
                  ),
                  home: const MyHomePage(
                    title: "home",
                    //channel = CanalController.connect('ws://echo.websocket.org');
                  ),
                )));
  }
}
