import 'dart:io';
import 'package:agenda_app/models/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {

  final Contact contact;

  FormPage({this.contact});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {

  Contact _obj = Contact();
  ContactHelper _contactHelper = ContactHelper();

  GlobalKey<FormState> _formKey = GlobalKey();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEdited = false;

  @override
  void initState(){
    super.initState();

    if(widget.contact != null)
      this._obj = Contact.fromMap(widget.contact.toMap());
      this._nameCtrl.text = this._obj.name;
      this._emailCtrl.text = this._obj.email;
      this._phoneCtrl.text = this._obj.phone;

    this._nameCtrl.addListener((){
      this._isEdited = true;
      setState(() {
        this._obj.name = this._nameCtrl.text;
      });
    });
    this._emailCtrl.addListener(onChange);
    this._phoneCtrl.addListener(onChange);
  }

  void saveData() async {
    this._obj.name = this._nameCtrl.text;
    this._obj.email = this._emailCtrl.text;
    this._obj.phone = this._phoneCtrl.text;

    if (this._obj.id != null)
      await this._contactHelper.updateContact(this._obj);
    else
      await this._contactHelper.saveContact(this._obj);
    Navigator.pop(context, true);
  }

  void onChange(){
    this._isEdited = true;
  }

  Future<bool> _requestPop(){
    if(this._isEdited){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Descartar alterações?'),
            content: Text('Se sair as alterções serão perdidas.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancelar'),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Sim'),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this._requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(this._obj.name ?? 'Novo Contato'),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: this._formKey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: this._obj.img != null ? FileImage(File(this._obj.img)) : AssetImage('images/user.png')
                      )
                    )
                  ),
                  onTap: (){
                    ImagePicker.pickImage(source: ImageSource.camera).then((file){
                      if (file == null) return;
                      setState(() {
                        this._obj.img = file.path;
                      });
                    });
                  },
                ),
                TextFormField(
                  controller: this._nameCtrl,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value){
                    if(value.isEmpty)
                      return 'Este campo é obrigatório!';
                  },
                ),
                TextFormField(
                  controller: this._emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value){
                    if(value.isEmpty)
                      return 'Este campo é obrigatório!';
                  },
                ),
                TextFormField(
                  controller: this._phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Telefone'),
                  validator: (value){
                    if(value.isEmpty)
                      return 'Este campo é obrigatório!';
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Salvar',
          backgroundColor: Colors.red,
          child: Icon(Icons.save),
          onPressed: (){
            if(this._formKey.currentState.validate()){
              this.saveData();
            }
          },
        ),
      ),
    );
  }
}
