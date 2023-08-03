import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  TextEditingController qrController = TextEditingController();

  Future<List<BluetoothDevice>> getDevices() async {
    devices = await printer.getBondedDevices();
    print('devicenya ada ga ' + devices.length.toString());
    setState(() {});
    return printer.getBondedDevices();
  }

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  openDialog(bytes) {
    getDevices().then(
      (value) => {
        Future.delayed(
          Duration.zero,
          () {
            showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: const Text('Printer Settings'),
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          DropdownButton<BluetoothDevice>(
                              hint: const Text('Select Thermal Printer'),
                              value: selectedDevice,
                              items: value
                                  .map((e) => DropdownMenuItem(
                                        child: Text(e.name.toString()),
                                        value: e,
                                      ))
                                  .toList(),
                              onChanged: (device) {
                                setState(() {
                                  selectedDevice = device;
                                });
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    printer.connect(selectedDevice!);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Connected'),
                                      ),
                                    );
                                  },
                                  child: const Text('Connect')),
                              ElevatedButton(
                                  onPressed: () {
                                    printer.disconnect();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Disconnected'),
                                      ),
                                    );
                                  },
                                  child: const Text('Disconnect'))
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if ((await printer.isConnected)!) {
                                print('printed');
                                // printer.printNewLine();
                                // printer.printCustom('testing Printer', 2, 1);
                                // printer.printNewLine();
                                // printer.printNewLine();
                                // printer.printCustom('testing Printer', 1, 1);
                                // printer.printQRcode(
                                //     '12345678910111213141718192021212223242526272829303132333435363738394041424344454647484950',
                                //     250,
                                //     250,
                                //     1);
                                // try {
                                //   const String qrData = 'example.com';
                                //   const double qrSize = 200;
                                //   final uiImg = await QrPainter(
                                //     data: qrData,
                                //     version: QrVersions.auto,
                                //     gapless: false,
                                //   ).toImageData(qrSize);
                                //   final dir = await getTemporaryDirectory();
                                //   final pathName = '${dir.path}/qr_tmp.png';
                                //   final qrFile = File(pathName);
                                //   final imgFile = await qrFile.writeAsBytes(
                                //       uiImg!.buffer.asUint8List());
                                //   final img =
                                //       decodeImage(imgFile.readAsBytesSync());
                                //       printer.printImage(imageFile.path);
                                // } catch (e) {
                                //   print(e);
                                // }

                                printer.printImageBytes(bytes);

                                printer.printNewLine();
                                printer.printNewLine();
                                printer.printNewLine();
                                print('qr printed');
                                // printer.printQRcode(
                                //     '00020101021226650014ID.SPINPAY.WWW01189360081632110103190214131432110103190303UBE51440014ID.CO.QRIS.WWW0215ID20210661250750303UBE52047523530336054065000.05802ID5912Safe Parking6013Jakarta Pusat61051034062360704A334602464b60fe97896267c07fc1b1863048D10',
                                //     255,
                                //     255,
                                //     0);
                                // printer.printImage('/assets/images/logo.png');

                                print('new line');
                                // printer.printNewLine();
                                // printer.printNewLine();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Harap connect dahulu.'),
                                  ),
                                );
                              }
                            },
                            child: Text('Test Print'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Ok'))
                    ],
                    // content: DropdownButton(
                    //   value: ,
                    //   items: [],
                    //   onChanged: (value) {},
                    // ),
                  );
                },
              ),
            );
          },
        )
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          TextFormField(
            controller: qrController,
          ),
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: Text(
              'change qr data',
            ),
          ),
          Center(
            child: SizedBox(
              height: 250,
              width: 250,
              child: QrImageView(
                data: qrController.text,
              ),
            ),
          ),
          Column(
            children: [
              DropdownButton<BluetoothDevice>(
                  hint: const Text('Select Thermal Printer'),
                  value: selectedDevice,
                  items: devices
                      .map((e) => DropdownMenuItem(
                            child: Text(e.name.toString()),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (device) {
                    setState(() {
                      selectedDevice = device;
                    });
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        printer.connect(selectedDevice!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connected'),
                          ),
                        );
                      },
                      child: const Text('Connect')),
                  ElevatedButton(
                      onPressed: () {
                        printer.disconnect();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Disconnected'),
                          ),
                        );
                      },
                      child: const Text('Disconnect'))
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if ((await printer.isConnected)!) {
                    print('printed');
                    QrPainter(
                      gapless: true,
                      data: qrController.text,
                      eyeStyle: const QrEyeStyle(
                          color: Colors.black, eyeShape: QrEyeShape.square),
                      emptyColor: Colors.white,
                      version: QrVersions.auto,
                    ).toImageData(255).then((value) {
                      Uint8List imageBytesFromAsset = value!.buffer.asUint8List(
                          value.offsetInBytes, value.lengthInBytes);
                      // printer.printCustom(qrController.text, 3, 0);
                      printer.printNewLine();
                      printer.printImageBytes(imageBytesFromAsset);
                      printer.printNewLine();
                      printer.printNewLine();
                      printer.printNewLine();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap connect dahulu.'),
                      ),
                    );
                  }
                },
                child: Text('Test Print'),
              ),
            ],
          ),
          // Center(
          //   // Center is a layout widget. It takes a single child and positions it
          //   // in the middle of the parent.
          //   child: TextButton(
          //     onPressed: () async {
          //       ByteData? qrBytes = await QrPainter(
          //         gapless: true,
          //         data:
          //             "00020101021226650014ID.SPINPAY.WWW01189360081632110103190214131432110103190303UBE51440014ID.CO.QRIS.WWW0215ID20210661250750303UBE52047523530336054065000.05802ID5912Safe Parking6013Jakarta Pusat61051034062360704A334602464b60fe97896267c07fc1b1863048D10",
          //         eyeStyle: const QrEyeStyle(
          //             color: Colors.black, eyeShape: QrEyeShape.square),
          //         emptyColor: Colors.white,
          //         version: QrVersions.auto,
          //       ).toImageData(255);

          //       // ByteData bytesAsset =
          //       //     await rootBundle.load("assets/images/qr285.png");
          //       Uint8List imageBytesFromAsset = qrBytes!.buffer
          //           .asUint8List(qrBytes.offsetInBytes, qrBytes.lengthInBytes);
          //       openDialog(imageBytesFromAsset);
          //     },
          //     child: Text('print'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
