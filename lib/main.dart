import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(const WifiAuditorApp());
}

class WifiAuditorApp extends StatelessWidget {
  const WifiAuditorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فاحص الواي فاي',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> devices = [];
  bool isScanning = false;
  String? wifiName, wifiIP;

  Future<void> scanNetwork() async {
    var status = await Permission.location.request();
    if (!status.isGranted) return;

    setState(() {
      isScanning = true;
      devices.clear();
    });

    final info = NetworkInfo();
    wifiName = await info.getWifiName();
    wifiIP = await info.getWifiIP();

    if (wifiIP!= null) {
      final String subnet = wifiIP!.substring(0, wifiIP!.lastIndexOf('.'));
      final stream = NetworkAnalyzer.discover2(subnet, 80);

      stream.listen((NetworkAddress addr) {
        if (addr.exists) {
          setState(() {
            devices.add(addr.ip);
          });
        }
      }).onDone(() {
        setState(() => isScanning = false);
      });
    } else {
      setState(() => isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فاحص الأجهزة المتصلة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.wifi),
                title: Text(wifiName?? 'غير متصل'),
                subtitle: Text('IP: ${wifiIP?? '---'}'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isScanning? null : scanNetwork,
              icon: isScanning
                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search),
              label: Text(isScanning? 'جاري الفحص...' : 'فحص من متصل'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.devices),
                    title: Text(devices[index]),
                    subtitle: const Text('جهاز متصل'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
