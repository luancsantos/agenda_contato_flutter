import 'dart:io';

import 'package:agenda_contato_app/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  bool _usedEdited = false;
  Contact _editedContact;

  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if(widget.contact == null){
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _phoneController.text = _editedContact.phone;
      _emailController.text = _editedContact.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name ?? 'Novo Contato'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              if(_editedContact.name != null && _editedContact.name.isNotEmpty){
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          body:  SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                GestureDetector( //faz com que o ca
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null ?
                            FileImage(File(_editedContact.img)) :
                            AssetImage('lib/images/user.jpg')
                        ),
                      ),
                    ),
                  ),
                  onTap: (){
                    _picker.getImage(
                        source: ImageSource.camera).then((file) => {
                        setState((){
                          _editedContact.img = file.path;
                        }),
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        focusNode: _nameFocus,
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        onChanged: (text) {
                          _usedEdited = true;
                          setState(() {
                            _editedContact.name = text;
                          });
                        },
                      ),
                      Divider(),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        onChanged: (text) {
                          _usedEdited = true;
                          setState(() {
                            _editedContact.phone = text;
                          });
                        },
                        keyboardType: TextInputType.phone,
                      ),
                      Divider(),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        onChanged: (text) {
                          _usedEdited = true;
                          setState(() {
                            _editedContact.email = text;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

Future<bool> _requestPop(){
    if(_usedEdited) {
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Descartar Alterações'),
            content: Text('Se sair as alterações serão perdidas.'),
            actions: [
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar')),
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Sim')),
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}