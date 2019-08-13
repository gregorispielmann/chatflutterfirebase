import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

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

  // leitura do firebase
  // Firestore.instance.collection('mensagens').snapshots().listen((items){
    
  //   for(var msgs in items.documents){
  //     print(msgs.data);
  //   }
  // });

  // CHAMA WIDGET APP PRINCIPAL
  runApp(MyApp());

}

// padronizando tema
final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefault = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);
// padronizando tema


// funcao manda msg
_handleSubmitted(text) async {
  // print(text);
  await _ensureLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imgUrl}){
  Firestore.instance.collection('messages').add(
    {
      'text': text,
      'imgUrl': imgUrl,
      'senderName': _googleSignIn.currentUser.displayName,
      'senderPhotoUrl': _googleSignIn.currentUser.photoUrl,
      "senderDate": new DateTime.now().toIso8601String()
    }
  );
}

// LOGANDO GOOGLE E FIREBASE
final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<FirebaseUser> _ensureLoggedIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  print("signed in " + user.displayName);
  return user;
}
// FIM DO LOGIN


// INICIO APP PRINCIPAL

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
/// FIM APP

// CHAT SCREEN WIDGET
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
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 4.0 : 0.0,
        ),
        body: Column(
          children: <Widget>[
          Expanded(
            child:
            StreamBuilder(
              stream: Firestore.instance.collection('messages').orderBy('senderDate').snapshots(),
              builder: (context,snapshot){
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: 
                        CircularProgressIndicator(),
                      );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return ListView.builder(
                      itemBuilder: (context,index){
                        List newList = snapshot.data.documents.reversed.toList();
                        return ChatMessage(newList[index].data);
                      },
                      itemCount: snapshot.data.documents.length,
                      reverse: true,
                    );
                }
              }
            )
          ),
          Divider(height: 1,),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor
            ),
            child: TextComposer(),
          ),]))
    );
  }
}

// FIM CHAT SCREEN WIDGET

// TEXT COMPOSER WIDGET
class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;
  final _messageController = TextEditingController();

  void _reset(){
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: Theme.of(context).platform == TargetPlatform.iOS ? 
        BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]))
        ) :
        null,
        child: Row(children: <Widget>[
          Container(child: 
            IconButton(icon: Icon(Icons.photo_camera),
            onPressed: () async {
              await _ensureLoggedIn();
              File imgFile = await ImagePicker.pickImage(source: ImageSource.gallery);
              if(imgFile == null ) return;
               StorageUploadTask task = FirebaseStorage.instance.ref().child(_googleSignIn.currentUser.id.toString() +
                DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);
                StorageTaskSnapshot taskSnapshot = await task.onComplete;
                String url = await taskSnapshot.ref.getDownloadURL();
                _sendMessage(imgUrl: url);

            },
            )
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration.collapsed(
              hintText: 'Digite sua mensagem',
              ),
              onChanged: (text){
                setState(() {
                  _isComposing = text.length > 0;
                });
            },
            // enviar ao clicar enter
            onSubmitted: (text){
              _handleSubmitted(text);
              _reset();
            },          
            )
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Theme.of(context).platform == TargetPlatform.iOS ? 
            CupertinoButton(
              child: Text('Enviar'),
              onPressed: _isComposing ? () {
                _handleSubmitted(_messageController.text);
                _reset();
              } : null,
             ) :
            IconButton(
              onPressed: _isComposing ? (){
                _handleSubmitted(_messageController.text);
                _reset();
              } : null,
              icon: Icon(Icons.message),
            )
          )
        ],),
      ),
    );
  }


}

// FIM TEXT COMPOSER WIDGET

// CHAT MESSAGE WIDGET
  class ChatMessage extends StatelessWidget {

    final Map<String, dynamic> data;

    ChatMessage(this.data);

    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhotoUrl']),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text(data['senderName'],
              style: 
              Theme.of(context).textTheme.subhead,
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: data['imgUrl'] != null ?
              Image.network(data['imgUrl'], width: 200,) :
              Text(data['text']),
            ),
          ],),)
        ],)
      );
    }
  }

  // FIM CHAT MESSAGE WIDGET

 