import 'dart:core';
import 'package:flutter/services.dart';
import 'package:migrateci/about.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:http/http.dart' as http;
import 'package:migrateci/migrate_proccess.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migrate CI',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Migrate CI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];
  var oldTel = "";
  var newNum = "";
  bool tuto = false;
  final dayMonth = DateTime.now().day;
  final month = DateTime.now().month;

  Map<String, Color> contactsColorMap = new Map();

  @override
  void initState() {
    super.initState();
    getPermissions();
  }


  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
    }
  }

  callBox() async{
    if(!tuto){
      await alertBox("INFO", "Pour selectionner un contact, veuillez maintenir votre doigt sur le numéro du contact 😉."
          , "OKAY", Icons.info_outline, Colors.orange, false);
      setState(() {
        tuto = true;
      });
    }
  }

  getAllContacts() async {
    List colors = [
      Colors.green,
      Colors.indigo,
      Colors.yellow,
      Colors.orange
    ];
    int colorIndex = 0;
    List<Contact> _contacts = [];
    await Contacts.streamContacts(withThumbnails: false, withHiResPhoto: false).forEach((contact) {
      _contacts.add(contact);
    });

    _contacts.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    setState(() {
      contacts = _contacts;
      newNum = "";
      oldTel = "";
    });
  }

  // Allow to show all phone numbers of a contact without repetition / del redundant number
  contactShow(Contact contact){
    var tel =[];
    var telF = "";

    if (contact.phones.length == 0){return " ";}
    else if(contact.phones.length > 0){
      for (int i = 0; i < contact.phones.length; i++) {
        var telT = contact.phones.elementAt(i).value.replaceAll(" ", "");
        if(tel.contains(telT) == false){tel.add(telT);}
      }
      tel.forEach((element) {telF = telF + element+"\n";});
    }
    return telF;
  }


  // Allow migration
  changeContact(Contact contact) async{
    var contactSave;
    var newTel;
    var data;

    for (int i = 0; i < contact.phones.length; i++){
      data = migration(contact.phones.elementAt(i).value); //get new number
      if(data == "" || data == null){break;}
      newTel = data;
      contact.phones.elementAt(i).value = newTel; // join new number to contact
    }

      contactSave = contact; // Backup contact with new number
      Contacts.deleteContact(contact); // delete old contact
      Contacts.addContact(contactSave); // Create new contact with new number
  }

  // Migrate one contact, same process with changeContact()
  changeContactOne(Contact contact) async{
    var contactSave;
    var newTel;
    var data;

    for (int i = 0; i < contact.phones.length; i++){
      data = migration(contact.phones.elementAt(i).value); ///
      newTel = data;
      contact.phones.elementAt(i).value = newTel;
    }

    contactSave = contact;
    Contacts.deleteContact(contact);
    setState(() {
      contacts.clear();
    });
    Contacts.addContact(contactSave);
    getAllContacts();
  }

  // Back to 8 length
  changeContactBack(Contact contact) async{
    var contactSave;
    var newTel;
    var data;

    for (int i = 0; i < contact.phones.length; i++){
      var foo = contact.phones.elementAt(i).value;
      foo = foo.replaceAll(" ", "");
      data = prefixDeleter(foo, foo.length);
      newTel = data;
      contact.phones.elementAt(i).value = newTel;
    }

    contactSave = contact;
    Contacts.deleteContact(contact);
    setState(() {
      contacts.clear();
    });
    Contacts.addContact(contactSave);
    getAllContacts();
  }


  // Allow to show future number without save it
  changeContactPreview(Contact contact) async{
    var newTel = [];
    var data;

    setState(() {
      oldTel = "";
      newNum = "";
      oldTel = contactShow(contact);
    });

    for (int i = 0; i < contact.phones.length; i++) {
        data = migration(contact.phones.elementAt(i).value);

        if (newTel.contains(data) == false){ // Allow to not have repetition
          newTel.add(data);
          setState(() {
            newNum = newNum + data + "\n" ;
          });
        }
      }
  }


  // Function for MIGRATE Btn, migrate all contacts
  weMigrate(List<Contact> contact) async {

    await alertBox("INFO", "Seul les numéros ivoiriens migreront vers 10 chiffres ✨✨", "SUPER", Icons.info_outline, Colors.orange, false);
    if ((dayMonth >= 1) && (month >= 2)) {
        contact.forEach((element) {
          changeContact(element);
        });
        setState(() {
          contacts.clear();
        });
        //getAllContacts();
        alertBox("FELICITATION",
            "Vous avez migré tous vos numéros Ivoirien avec succès !",
            "SUPER",
            Icons.check, Colors.green, true);
      }
      else {
        alertBox("ATTENTION",
              "Vous ne pouvez pas migrer vos contacts avant le 1er Février 2020.",
              "COMPRIS",
              Icons.info_outline, Colors.orange, false);
      }
  }


  // Allow to show custom alertBox
  Future<Null>alertBox(String title, String msg, String nameBtn, IconData icon, Color iconColor, bool fn) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(70.0)),
            ),
            child: SimpleDialog(
              title: textStyle(title, TextAlign.center, Colors.green, FontWeight.bold, 20),
              children: [
                Icon(icon, size: 50, color: iconColor,),
                Container(height: 10,),
                textStyle(msg, TextAlign.center, Colors.black, FontWeight.normal, 15),
                Container(height: 10,),
                ButtonTheme(
                  padding: EdgeInsets.only(bottom: 0.0),
                  minWidth: 100.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: (){
                            if(fn) {
                              getAllContacts();
                              Navigator.pop(context);
                            }
                            else{Navigator.pop(context);}
                          },
                          child: textStyle(nameBtn, TextAlign.center, Colors.white, FontWeight.bold, 15),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepOrange,)
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  // Allow to have custom text
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

  // Allow to show new and old contact
  Future<Null> contactView(Contact contact) async {
    await changeContactPreview(contact);
    await callBox();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: textStyle(
              "${contact.displayName}", TextAlign.center, Colors.black,
              FontWeight.bold, 25),
          contentPadding: EdgeInsets.all(5.0),
          children: [
            textStyle("\nAncien(s) numéro(s):", TextAlign.start, Colors.black,
                FontWeight.bold, 20),
            textStyle(
                "$oldTel", TextAlign.start, Colors.black, FontWeight.normal,
                15),
            textStyle(
                "\nNouveau(x) numéro(s):", TextAlign.start, Colors.black,
                FontWeight.bold, 20),
            textStyle("${newNum != "" ? newNum : contactShow(contact)}",
                TextAlign.start, Colors.black, FontWeight.normal, 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OKAY", style: TextStyle(color: Colors.white),),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        elevation: 10.0)),
          ])
        ]);
      },
    );
  }

  // Make Choice to go to 8 or 10 length
  Future<Null> makeChoice(Contact contact) async {
    await changeContactPreview(contact);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
            title: textStyle(
                "QUE VOULEZ-VOUS FAIRE ?", TextAlign.center, Colors.black,
                FontWeight.bold, 25),
            contentPadding: EdgeInsets.all(5.0),
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () async{ await changeContactOne(contact); Navigator.pop(context); },
                        child: Text("PASSER A 10 CHIFFRES", style: TextStyle(color: Colors.white),),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            elevation: 10.0)),
                    TextButton(
                        onPressed: () async{ await changeContactBack(contact); Navigator.pop(context);},
                        child: Text("REVENIR A 8 CHIFFRES", style: TextStyle(color: Colors.white),),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            elevation: 10.0)),
                  ])
            ]);
      },
    );
  }


  gotoAbout(){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
      return About();
    }));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                  'MENU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 75,
                    color: Colors.white70,
                  )
              ),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
            ),
            ListTile(
              title: Text('Accueil'),
              leading: Icon(Icons.home_sharp),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                //getAllContacts();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('A propos'),
              leading: Icon(Icons.info_sharp),
              trailing: Icon(Icons.keyboard_arrow_right_sharp),
              onTap: () {
                gotoAbout();
              },
            ),
          ],
        ),
      ),

      body: Container(
        padding: EdgeInsets.all(0),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.deepOrange,
              child: Column(
                children: [
                  Text(
                    "AKWABA !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      fontSize: 35,
                    ),
                  ),
                  Container(height: 10,),
                  Text(
                    "Cliquez sur un contact pour voir son futur numéro à 10 chiffres ou Selectionnez le pour le faire migrer.😎",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Container(height: 10,)
                ],
              ),
            ),
            Expanded(
              child: (contacts.isNotEmpty == true)? ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = contacts[index];

                  var baseColor = contactsColorMap[contact.displayName] as dynamic;

                  Color color1 = baseColor[800];
                  Color color2 = baseColor[400];

                  return InkWell(
                    onTap: () => contactView(contact),
                    onLongPress: () => makeChoice(contact),
                    child: ListTile(
                        title: Text((contact.displayName is String)?contact.displayName :" "),
                        subtitle: Text(contactShow(contact)),
                        leading: (contact.avatar != null && contact.avatar.length > 0) ?
                        CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        ) :
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    colors: [
                                      color1,
                                      color2,
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight
                                )
                            ),
                            child: CircleAvatar(
                                child: Text(
                                    contact.initials(),
                                    style: TextStyle(
                                        color: Colors.white
                                    )
                                ),
                                backgroundColor: Colors.transparent
                            )
                        )
                    ),
                  );
                },
              )
                  : Center (child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  textStyle("Chargement des contacts, Veuillez patienter svp.", TextAlign.center, Colors.black, FontWeight.bold, 16),
                  Container(height: 10,),
                  const CircularProgressIndicator(),
                ],
                ),
              )
            ),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              margin: EdgeInsets.all(10.0),
              child:
              TextButton(
                  onPressed: () =>  weMigrate(contacts),
                  child: Text("MIGRER TOUS SES CONTACTS VERS 10 CHIFFRES", style: TextStyle(color: Colors.white),),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,)
              ),
            )
          ],
        ),
      ),
    );
  }
}
