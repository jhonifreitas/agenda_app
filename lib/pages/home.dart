import 'dart:io';

import 'package:flutter/material.dart';
import 'package:agenda_app/models/contact.dart';
import 'package:agenda_app/pages/form.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper _contactHelper = ContactHelper();

  List<Contact> _objectList = List();

  @override
  void initState(){
    super.initState();
    this._getData();
  }

  void _getData(){
    this._contactHelper.getAllContact().then((data){
      setState(() {
        this._objectList = data;
      });
    });
  }

  void _goToForm({Contact contact}) async {
    final obj = await Navigator.push(context, MaterialPageRoute(builder: (context) => FormPage(contact: contact,)));
    if(obj != null)
      this._getData();
  }

  void _orderList(OrderOptions order){
    switch(order){
      case OrderOptions.orderaz:
        this._objectList.sort((a, b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        this._objectList.sort((a, b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de A-Z'),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de Z-A'),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: this._orderList,
          )
        ],
      ),
      body: this._objectList.length > 0 ? this.buildList() : this.buildMsgErr(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar',
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: (){
          this._goToForm();
        },
      ),
    );
  }

  void _showOptions(BuildContext context, Contact contact){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    child: Text('Ligar', style: TextStyle(fontSize: 20, color: Colors.red),),
                    onPressed: (){
                      Navigator.pop(context);
                      launch('tel:$contact.phone');
                    },
                  ),
                  FlatButton(
                    child: Text('Editar', style: TextStyle(fontSize: 20, color: Colors.red),),
                    onPressed: (){
                      Navigator.pop(context);
                      this._goToForm(contact: contact);
                    },
                  ),
                  FlatButton(
                    child: Text('Excluir', style: TextStyle(fontSize: 20, color: Colors.red),),
                    onPressed: (){
                      Navigator.pop(context);
                      this._contactHelper.deleteContact(contact.id);
                      this._getData();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
      onTap: (){
        this._showOptions(context, contact);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: contact.img != null ? FileImage(File(contact.img)) : AssetImage('images/user.png')
                  )
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
