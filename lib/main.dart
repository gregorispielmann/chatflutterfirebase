import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {

  //exemplo escrevendo dados
  // Firestore.instance.collection('mensagens').document('msg1').setData({'from':'Daniel', 'text': 'Olá'});
  // Firestore.instance.collection('mensagens').document().collection('arqmidia').document().setData({'from':'Marcos', 'text': 'Olá! Tudo bem?'});

  // Firestore.instance.collection('usuarios').document('greg').setData({'name':'gregori', 'surname': 'spielmann'});
  // Firestore.instance.collection('usuarios').document('tali').setData({'name':'talita', 'surname': 'spielmann'});

  //exemplo lendo dados
  // DocumentSnapshot user = await Firestore.instance.collection('usuarios').document('greg').get();
  // print(user.data);

  // QuerySnapshot users = await Firestore.instance.collection('usuarios').getDocuments();
  // for (var user in users.documents) {
  //   print(user.data);
  // }

  Firestore.instance.collection('mensagens').snapshots().listen((items){
    
    for(var msgs in items.documents){
      print(msgs.data);
    }

  });

  runApp(MyApp());

}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefault = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatApp',
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS ? kIOSTheme : kDefault,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, //evitar usar a area debaixo do iphone setar true
      top: false, //evitar usar a area do notch (iphone x) setar true
      child: Scaffold(
        appBar: AppBar(
          title: Text('ChatApp'),
          centerTitle: true,
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: Column(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor
            ),
            child: TextComposer(),
          ),
        ],),
      ) 
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}