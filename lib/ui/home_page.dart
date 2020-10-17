import 'dart:io';

import 'package:agenda_contato_app/helpers/contact_helper.dart';
import 'package:agenda_contato_app/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState(){
    super.initState();

    _getAllContacts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                    child: Text('Ordernar de A-Z'),
                    value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text('Ordernar de Z-A'),
                  value: OrderOptions.orderza,
                ),
              ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
          return _contactCard(context, index);
      }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('lib/images/user.jpg')
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacts[index].name ?? '',
                      style: TextStyle(fontSize: 17.0,
                      fontWeight: FontWeight.bold),
                    ),
                      Text(contacts[index].email ?? '',
                      style: TextStyle(fontSize: 15.0
                      ),
                    ),
                    Text(contacts[index].phone ?? '',
                      style: TextStyle(fontSize: 15.0,
                      ),
                    ),
                    TextButton(
                        onPressed: (){},
                        child: const Text('Visualizar')
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
            onClosing: (){},
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: (){
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                        child: Text('Ligar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                        child: Text('Editar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: (){
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                        child: Text('Excluir',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        );
      }
    );
  }
  void _callingToPhone() async{
    const url = 'tel:21974027101';
    if(await canLaunch(url)){
      await launch(url);
    } else {
      throw 'Não foi possível fazer ligação para o nímero informado';
    }
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact))
    );
    if(recContact != null) {
      if(contact != null){
        await helper.updateContact(recContact);
        _getAllContacts();
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
         return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  _getAllContacts(){
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}

