import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  @override
  void initState() {
    final sockeService = Provider.of<SocketService>(context, listen: false);

    sockeService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands =
        (payload as List<dynamic>).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final sockeService = Provider.of<SocketService>(context, listen: false);
    sockeService.socket.off('active-bands');
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sockeService = Provider.of<SocketService>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black45),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: sockeService.serverStatus != ServerStatus.Online
                ? Icon(
                    Icons.offline_bolt,
                    color: Colors.red[100],
                  )
                : Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  ),
          )
        ],
        backgroundColor: Colors.white,
      ),
      body:
          // SingleChildScrollView(
          //   child:
          Column(children: [
        Container(
            height: size.height * 0.35,
            child: _ShowGraph(
              bands: bands,
            )),
        Divider(
          thickness: 3,
        ),
        Container(
          height: size.height * 0.5,
          child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, int index) => _bandTile(bands[index])),
        )
      ]),
      // ),
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBand),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          socketService.socket.emit('delete-band', {
            'id': band.id,
          });
        }
      },
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
          socketService.socket.emit('vote-band', {'id': band.id});
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
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (bandName.isNotEmpty) {
      socketService.socket.emit('add-band', {'bandName': bandName});
    }
    Navigator.pop(context);
  }
}

class _ShowGraph extends StatelessWidget {
  final List<Band> bands;
  _ShowGraph({super.key, required this.bands});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Map<String, double> dataMap = {};
    //  = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        height: 100,
        width: size.width,
        child: dataMap.isEmpty
            ? Text('NO DATA')
            : PieChart(
                dataMap: dataMap,
                animationDuration: Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                // colorList: colorList,
                initialAngleInDegree: 0,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                centerText: "Bands",
                legendOptions: LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  // legendShape: _BoxShape.circle,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesInPercentage: false,
                  showChartValuesOutside: false,
                  decimalPlaces: 1,
                ),
                // gradientList: ---To add gradient colors---
                // emptyColorGradient: ---Empty Color gradient---
              )
        // PieChart(dataMap: dataMap)
        );
  }
}
