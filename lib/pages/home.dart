import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agenda_app/models/contact.dart';
import 'package:agenda_app/pages/form.dart';
// import 'package:agenda_app/services/storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper contact = ContactHelper();

  List<Contact> _objectList = List();

  @override
  void initState(){
    super.initState();
    contact.getAllContact().then((data){
      setState(() {
        this._objectList = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: this._objectList.length > 0 ? this.buildList() : this.buildMsgErr(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar',
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => FormPage()));
        },
      ),
    );
  }

  Widget buildList(){
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: this._objectList.length,
      itemBuilder: (context, index){
        return this.buildCard(context, this._objectList[index]);
      },
    );
  }

  Widget buildCard(BuildContext context, Contact contact){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contact.img != null ? FileImage(File(contact.img)) : AssetImage('images/user.png')
                  )
                ),
                child: Column(
                  children: <Widget>[
                    Text(contact.name ?? 'Sem registro',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(contact.email ?? 'Sem registro',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(contact.phone ?? 'Sem registro',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMsgErr(){
    return Center(child: Text('Nenhum registro encontrado!', style: TextStyle(fontSize: 20),));
  }
}
