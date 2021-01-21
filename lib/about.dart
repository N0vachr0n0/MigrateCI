import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget{
  @override
  _About createState() => _About();
}

_github() async {
  const url = 'https://github.com/N0vachr0n0';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Text textStyle(String data, TextAlign align, Color color, FontWeight fw, double fs){
  return Text("$data",
    textAlign: align,
    style: TextStyle(
      color: color,
      fontWeight: fw,
      fontSize: fs,
    ),
  );
}

class _About extends State<About>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("A propos"),
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textStyle("MIGRATE CI", TextAlign.center, Colors.deepOrange, FontWeight.bold, 25),
                Container(height: 15,),
                textStyle("Fais avec ❤ par N0vachr0n0.", TextAlign.center, Colors.black, FontWeight.normal, 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textStyle("Retrouvez tous nos projets sur", TextAlign.center, Colors.black, FontWeight.normal, 15),
                    TextButton(
                      onPressed: (){_github();},
                      child: Text('GitHub'),
                    ),
                  ],
                )
              ],
            ),
          ),)
    );
  }
}