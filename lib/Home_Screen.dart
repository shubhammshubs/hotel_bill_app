//
//
// import 'dart:convert';
//
// import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:waiter_bill_app/Login_Screen.dart';
//
// import 'DisplayTableDataPage.dart';
// import 'Menu_List.dart';
// import 'Nav_menu.dart';
//
// class HomePage extends StatefulWidget {
//   final String mobileNumber;
//
//   HomePage({
//     Key? key,
//     required this.mobileNumber,
//   }) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final List<int> tableNumbers = List.generate(10, (index) => index + 1);
//   final List<int> bookedTables = [];
//   List<Map<String, dynamic>> orderData = [];
//   bool _isLoading = false;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
//
//   bool _loading = false;
//
//   bool _isMounted = false; // Add this line
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//
//     _isMounted = true; // Add this line
//     _handleBluetoothPermission();
//   }
//
//   Future<void> _handleBluetoothPermission() async {
//     var bluetoothPermissionStatus = await Permission.bluetooth.request();
//     var bluetoothScanPermissionStatus =
//         await Permission.bluetoothScan.request();
//
//     if (bluetoothPermissionStatus.isGranted &&
//         bluetoothScanPermissionStatus.isGranted) {
//       print("Bluetooth Permission Granted");
//       await _checkBluetoothStatus();
//     } else {
//       print("Bluetooth Permission Failed");
//     }
//   }
//
//   Future<void> _checkBluetoothStatus() async {
//     bool isBluetoothOn =
//         await BluetoothEnable.enableBluetooth.then((result) async {
//       // print("Bluetooth IS On Stage one");
//       await _connectToBluetoothPrinter();
//       return result == "true";
//     });
//
//     if (isBluetoothOn) {
//       print("Bluetooth IS On");
//       await _connectToBluetoothPrinter();
//     } else {
//       print("Bluetooth IS Off");
//     }
//   }
//
//   Future<void> _connectToBluetoothPrinter() async {
//     try {
//       setState(() {
//         _loading = true;
//       });
//
//       String printerName = "BlueTooth Printer";
//       String printerAddress = "DC:0D:30:CA:34:E6";
//
//       BluetoothDevice device = BluetoothDevice();
//       device.name = printerName;
//       device.address = printerAddress;
//
//       // print('Selected Bluetooth Device: ${device.name ?? 'Unknown'}');
//
//       if (await bluetoothPrint.isConnected == true) {
//         print('Already connected to ${device.name}');
//       } else {
//         await bluetoothPrint.connect(device);
//
//         if (bluetoothPrint.state == BluetoothPrint.CONNECTED) {
//           print('Connected to ${device.name} successfully.');
//         } else {
//           print('Connection failed. State: ${bluetoothPrint.state}');
//           return;
//         }
//       }
//
//       // print('Bluetooth connection successful. You can start printing or perform other tasks.');
//     } catch (e, stackTrace) {
//       print('Bluetooth connection error: $e');
//       print('Stack trace: $stackTrace');
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }
//
//   Future<void> fetchData() async {
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readorders';
//     final response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       setState(() {
//         orderData = List.from(data);
//       });
//     } else {
//       // Handle error
//       print('Failed to load data: ${response.statusCode}');
//     }
//   }
//
//   Future<bool> checkIfDataAvailable(int tableNumber) async {
//     List<Map<String, dynamic>> ordersForTable = orderData
//         .where((order) =>
//             order['order_table'] == tableNumber.toString() &&
//             order['order_status'] == 'In Process')
//         .toList();
//
//     return ordersForTable.isNotEmpty;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: NavBar(mobileNumber: widget.mobileNumber),
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text('Order App'),
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: Icon(Icons.menu),
//           onPressed: () {
//             _scaffoldKey.currentState?.openDrawer();
//             setState(() {});
//           },
//         ),
//         // Set this to false to hide the back button
//         // actions: [
//         //   IconButton(
//         //     icon: Icon(Icons.logout),
//         //     onPressed: () async {
//         //       // Implement your logout logic here
//         //       SharedPreferences prefs = await SharedPreferences.getInstance();
//         //       await prefs.clear();
//         //       Navigator.push(
//         //         context,
//         //         MaterialPageRoute(
//         //           builder: (context) => LoginScreen(
//         //             // latestInvoiceId: submittedInvoiceId
//         //           ),
//         //         ),
//         //       );
//         //       // Navigator.push(
//         //       //   context,
//         //       //   MaterialPageRoute(
//         //       //     builder: (context) => LoginScreen(
//         //       //     ),
//         //       //   ),
//         //       // );
//         //       },
//         //   ),
//         // ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await fetchData();
//         },
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: tableNumbers.length,
//           itemBuilder: (context, index) {
//             bool isTableBooked = bookedTables.contains(tableNumbers[index]);
//
//             List<Map<String, dynamic>> ordersForTable = orderData
//                 .where((order) =>
//                     order['order_table'] == tableNumbers[index].toString() &&
//                     order['order_status'] == 'In Process')
//                 .toList();
//
//             bool isTableInProcess = ordersForTable.isNotEmpty &&
//                 ordersForTable
//                     .any((order) => order['order_status'] == 'In Process');
//
//             return Padding(
//               padding: EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   bool isDataAvailable =
//                       await checkIfDataAvailable(tableNumbers[index]);
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MenuListPage(
//                         tableNumber: tableNumbers[index],
//                         mobileNumber: widget.mobileNumber,
//                       ),
//                     ),
//                   );
//
//                   // if (isDataAvailable) {
//                   //   Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //       builder: (context) => DisplayTableDataPage(tableNumber: tableNumbers[index]),
//                   //     ),
//                   //   );
//                   // } else {
//                   //   Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //       builder: (context) => MenuListPage(
//                   //           tableNumber: tableNumbers[index]
//                   //       ),
//                   //     ),
//                   //   );
//                   // }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   primary: isTableInProcess
//                       ? Colors.green
//                       : isTableBooked
//                           ? Colors.green
//                           : Colors.white,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Table ${tableNumbers[index]}'),
//                     // if (ordersForTable.isNotEmpty)
//                     //   Text(
//                     //     'Total Amount: ${ordersForTable[0]['product_amount']}',
//                     //   ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }






import 'dart:convert';

import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiter_bill_app/Login_Screen.dart';

import 'DisplayTableDataPage.dart';
import 'Menu_List.dart';
import 'Nav_menu.dart';

class HomePage extends StatefulWidget {
  final String mobileNumber;

  HomePage({
    Key? key,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> tableData = [];
  final List<int> bookedTables = [];
  List<Map<String, dynamic>> orderData = [];
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _loading = false;

  bool _isMounted = false; // Add this line

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTableData();

    _isMounted = true; // Add this line
    _handleBluetoothPermission();
  }

  Future<void> _handleBluetoothPermission() async {
    var bluetoothPermissionStatus = await Permission.bluetooth.request();
    var bluetoothScanPermissionStatus =
    await Permission.bluetoothScan.request();

    if (bluetoothPermissionStatus.isGranted &&
        bluetoothScanPermissionStatus.isGranted) {
      print("Bluetooth Permission Granted");
      await _checkBluetoothStatus();
    } else {
      print("Bluetooth Permission Failed");
    }
  }

  Future<void> _checkBluetoothStatus() async {
    bool isBluetoothOn =
    await BluetoothEnable.enableBluetooth.then((result) async {
      print("Bluetooth IS On Stage one");
      await _connectToBluetoothPrinter();
      return result == "true";
    });

    if (isBluetoothOn) {
      print("Bluetooth IS On");
      await _connectToBluetoothPrinter();
    } else {
      print("Bluetooth IS Off");
    }
  }

  Future<void> _connectToBluetoothPrinter() async {
    try {
        setState(() {
          _loading = true;
        });

      String printerName = "BlueTooth Printer";
      String printerAddress = "DC:0D:30:CA:34:E6";

      BluetoothDevice device = BluetoothDevice();
      device.name = printerName;
      device.address = printerAddress;

      print('Selected Bluetooth Device: ${device.name ?? 'Unknown'}');

      if (await bluetoothPrint.isConnected == true) {
        print('Already connected to ${device.name}');
        // await bluetoothPrint.connect(device);

      } else {
        await bluetoothPrint.connect(device);

        if (bluetoothPrint.state == BluetoothPrint.CONNECTED) {
          print('Connected to ${device.name} successfully.');
        } else {
          print('Connection failed. State: ${bluetoothPrint.state}');
          return;
        }
      }

      // print('Bluetooth connection successful. You can start printing or perform other tasks.');
    } catch (e, stackTrace) {
      print('Bluetooth connection error: $e');
      print('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
  Future<void> fetchTableData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readtablename';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        tableData = List.from(data);
      });
    } else {
      // Handle error
      print('Failed to load table data: ${response.statusCode}');
    }
  }

  Future<void> fetchData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readorders';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        orderData = List.from(data);
      });
    } else {
      // Handle error
      print('Failed to load data: ${response.statusCode}');
    }
  }

  Future<bool> checkIfDataAvailable(String tableName) async {
    String numericPart = tableName.replaceAll(RegExp(r'[^0-9]'), '');
    int parsedTableNumber = int.tryParse(numericPart) ?? 0;

    List<Map<String, dynamic>> ordersForTable = orderData
        .where((order) =>
    order['order_table'] == parsedTableNumber.toString() &&
        order['order_status'] == 'In Process')
        .toList();

    bool isDataAvailable = ordersForTable.isNotEmpty;
    return isDataAvailable;
  }

  Widget build(BuildContext context) {
    bool isTableBooked;

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavBar(mobileNumber: widget.mobileNumber),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Order App'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
            setState(() {});
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchTableData();
          await fetchData();
          await _connectToBluetoothPrinter();
        },
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
          ),
          itemCount: tableData.length,
          itemBuilder: (context, index) {
            isTableBooked = bookedTables.contains(tableData[index]['table_name']);

            List<Map<String, dynamic>> ordersForTable = orderData
                .where((order) =>
            order['order_table'] == tableData[index]['table_name'].toString() &&
                order['order_status'] == 'In Process')
                .toList();

            bool isTableInProcess = ordersForTable.isNotEmpty &&
                ordersForTable.any((order) => order['order_status'] == 'In Process');

            return FutureBuilder<bool>(
              future: checkIfDataAvailable(tableData[index]['table_name']),
              builder: (context, snapshot) {
                bool isDataAvailable = snapshot.data ?? false;

                String tableName = tableData[index]['table_name'];
                String numericPart = tableName.replaceAll(RegExp(r'[^0-9]'), '');
                int parsedTableNumber = int.tryParse(numericPart) ?? 0;

                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuListPage(
                            tableNumber: parsedTableNumber,
                            mobileNumber: widget.mobileNumber,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: isDataAvailable
                          ? Colors.green
                          : isTableBooked
                          ? Colors.green
                          : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(' ${tableData[index]['table_name']}'),
                        Text('Capacity ${tableData[index]['table_capacity']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
