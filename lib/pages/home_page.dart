import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(
      id: '1',
      name: 'Metalica',
      votes: 32,
    ),
    Band(
      id: '2',
      name: 'Radiohead',
      votes: 7,
    ),
    Band(
      id: '3',
      name: 'Beatles',
      votes: 9,
    ),
    Band(
      id: '4',
      name: 'Rolling',
      votes: 54,
    ),
    Band(
      id: '5',
      name: 'Pink Floyd',
      votes: 12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black45),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, int index) => _bandTile(bands[index])),
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBand),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
          padding: EdgeInsets.only(left: 8),
          child: Align(
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            ),
            alignment: Alignment.centerLeft,
          ),
          color: const Color.fromARGB(255, 234, 110, 101)),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  void addNewBand() {
    final textEditingController = TextEditingController();
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New Band Name'),
              content: TextField(
                controller: textEditingController,
              ),
              actions: [
                MaterialButton(
                    child: Text('Save'),
                    textColor: Colors.blue,
                    onPressed: () {
                      addBandToList(textEditingController.text);
                    })
              ],
            );
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('New Band Name'),
              content: CupertinoTextField(
                controller: textEditingController,
              ),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Save'),
                    onPressed: () {
                      addBandToList(textEditingController.text);
                    }),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            );
          });
    }
  }

  void addBandToList(String bandName) {
    if (bandName.isNotEmpty) {
      this.bands.add(
          new Band(name: bandName, id: DateTime.now().toString(), votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
