import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Status')),
      body: Center(child: Text('Status: ${socketService.serverStatus}')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketService.socket
              .emit('messageFromFlutter', {'message': 'hello from flutter'});
        },
      ),
    );
  }
}
