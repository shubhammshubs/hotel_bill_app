import 'dart:convert';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:waiter_bill_app/Home_Screen.dart';

class MenuListPage extends StatefulWidget {
  final int tableNumber;

  MenuListPage({required this.tableNumber});

  @override
  _MenuListPageState createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  List<Map<String, dynamic>> responseData = [];
  Map<String, int> itemQuantities = {};
  String selectedItemId = "";
  String submittedInvoiceId = ""; // Add this line
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> products = []; // List to store products from API
  List<Map<String, dynamic>> orderData = []; // Add this line
  String? selectedProduct;
  int selectedQuantity = 1;
  double totalAmount = 0.0; // Variable to store the total amount
  bool _isLoading = false;
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Fetch products from API when the widget is initialized
    fetchProducts();
    fetchData(); // Fetch order data when the widget is initialized
    _handleBluetoothPermission();
  }
  // Here we check the bluetooth Permission
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
  // Here we check the status of the Bluetooth Connection.
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
  // In this function connection to Printer code performed
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
      } else {
        await bluetoothPrint.connect(device);

        if (bluetoothPrint.state == BluetoothPrint.CONNECTED) {
          print('Connected to ${device.name} successfully.');
        } else {
          print('Connection failed. State: ${bluetoothPrint.state}');
          return;
        }
      }

      print(
          'Bluetooth connection successful. You can start printing or perform other tasks.');
    } catch (e, stackTrace) {
      print('Bluetooth connection error: $e');
      print('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  //  THis reads all the orders from the datebase
  // ** we filter that below the code for selected table and In Process Status **
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

  // This API is for Products to Display in Dropdown List
  Future<void> fetchProducts() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readproducts';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        products = List<Map<String, dynamic>>.from(
          json.decode(response.body) as List<dynamic>,
        );
      });
    } else {
      print('Failed to load products. Error: ${response.statusCode}');
    }
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    String formattedDate = '${now.day}-${now.month}-${now.year}';
    // print(formattedDate);

    return formattedDate;
  }

  void incrementQuantity() {
    setState(() {
      selectedQuantity++;
    });
  }

  void decrementQuantity() {
    if (selectedQuantity > 1) {
      setState(() {
        selectedQuantity--;
      });
    }
  }

  //  THis api is for removing the product form the table and api
  Future<void> removeProduct(
    String orderTable,
    String productName,
    String productQty,
    String productPrice,
    String productAmount,
  ) async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=remprod';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'order_table': orderTable,
        'product_name': productName,
        'product_qty': productQty,
        'product_price': productPrice,
        'product_amount': productAmount,
      },
    );

    if (response.statusCode == 200) {
      // Successful removal
      print('Product removed successfully');
// Reload the page by fetching the updated data
      fetchData();
      // Optionally, you can refresh the table or update the UI as needed.
    } else {
      // Handle error
      print('Failed to remove product: ${response.statusCode}');
    }
  }

  //  THis Creates the Table layout
  TableRow buildOrderTableRow(int serialNumber, Map<String, dynamic> order) {
    String productName = order['product_name'];
    int quantity = int.parse(order['product_qty']);
    double totalAmount = double.parse(order['product_amount']);
    double total = double.parse(order['product_price']);

    return TableRow(
      children: [
        TableCell(child: Center(child: Text(serialNumber.toString()))),
        TableCell(child: Center(child: Text(productName))),
        TableCell(child: Center(child: Text(quantity.toString()))),
        TableCell(child: Center(child: Text(total.toStringAsFixed(2)))),
        TableCell(child: Center(child: Text(totalAmount.toStringAsFixed(2)))),
        TableCell(
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () {
                // Add your logic to remove the product here
                removeProduct(
                  order['order_table'].toString(),
                  productName,
                  quantity.toString(),
                  total.toString(),
                  totalAmount.toString(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  //  This table is for in last row displaying the Grand Total.
  // here we check for the table which is In Process and calculete the items price for
  //  Grand Total.
  TableRow buildGrandTotalDisplay(int tableNumber) {
    List<Map<String, dynamic>> ordersForTable = orderData
        .where((order) =>
            order['order_table'] == tableNumber.toString() &&
            order['order_status'] == 'In Process')
        .toList();

    double grandTotal = ordersForTable.fold(0.0, (sum, order) {
      double quantity = double.parse(order['product_qty']);
      double productPrice = double.parse(order['product_price']);
      return sum + (quantity * productPrice);
    });

    //  This table is for in last row displaying the Grand Total.
    return TableRow(
      children: [
        const TableCell(child: SizedBox()), // Empty cell for spacing
        const TableCell(child: SizedBox()),
        const TableCell(child: SizedBox()),
        const TableCell(child: Center(child: Text('Grand Total:'))),
        TableCell(
          child: Center(child: Text(' ${grandTotal.toStringAsFixed(2)} ')),
        ),
        const TableCell(child: SizedBox()), //
      ],
    );
  }

  //  With this APi we change the status of the table from (In process) to (Completed).
  Future<void> completeOrder(
    String orderTable,
  ) async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=updateord';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'order_table': orderTable,
      },
    );
    if (response.statusCode == 200) {
      // Successful removal
      print('Product Completed successfully ${orderTable}');
      Fluttertoast.showToast(
          msg: 'Order Completed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
// Reload the page by fetching the updated data
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));

      // Optionally, you can refresh the table or update the UI as needed.
    } else {
      // Handle error
      print('Failed to Complete product: ${response.statusCode}');
    }
  }

  // THis is for Add Item button {adding the Item to Api for dispalying in the Table}.
  Future<void> addItemToOrder() async {
    DateTime now = DateTime.now();
    String orderDate = '${now.year}-${now.month}-${now.day}';
    String orderTime = '${now.hour}:${now.minute}:${now.second}';
    if (selectedProduct != null) {
      // Find the selected product details from the products list
      Map<String, dynamic>? selectedProductDetails = products
          .firstWhere((product) => product['product_name'] == selectedProduct);

      if (selectedProductDetails != null) {
        // Calculate the total amount
        double totalAmount = selectedQuantity *
            double.parse(selectedProductDetails['product_price']);

        // Make the API call
        final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=addorder';
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'product_name': selectedProductDetails['product_name'],
            'product_qty': selectedQuantity.toString(),
            'product_price': selectedProductDetails['product_price'],
            'product_amount': totalAmount.toString(),
            'order_number': '20',
            'order_table': widget.tableNumber.toString(),
            'order_date': orderDate,
            'order_time': orderTime,
          }..removeWhere((key, value) => value == null),
        );

        if (response.body == "Order Added Successfully.") {
          final snackBar = SnackBar(
            content: Text(
              'Item ${selectedProductDetails['product_name']} added to Cart.',
              textAlign: TextAlign.center,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          print('1212 ${response.body}');
          print('Item ${selectedProduct} added to Table');
        }
      } else {
        // Handle the case when the selected product is not found
        print('Selected product not found in the list.');
        // Optionally, show a message in the UI
        // You can add your own logic or UI feedback here
      }
    }
    // resetSelection();
    setState(() {
      selectedProduct = null;
      selectedQuantity = 1;
      totalAmount = 0.0;
    });
    fetchData();
    buildGrandTotalDisplay(widget.tableNumber);
  }

  // THis code is for the calculating the total of product and quantity.
  void updateTotal() {
    if (selectedProduct != null) {
      // Find the selected product details from the products list
      Map<String, dynamic>? selectedProductDetails = products
          .firstWhere((product) => product['product_name'] == selectedProduct);

      if (selectedProductDetails != null) {
        // Update the total based on the selected product and quantity
        totalAmount = selectedQuantity *
            double.parse(selectedProductDetails['product_price']);
      } else {
        // Handle the case when the selected product is not found
        print('Selected product not found in the list.');
        // Optionally, show a message in the UI
        // You can add your own logic or UI feedback here
      }
    }
  }

  // This is calling again for AddToBill
  double calculateGrandTotal(List<Map<String, dynamic>> orders) {
    double grandTotal = orders.fold(0.0, (sum, order) {
      double quantity = double.parse(order['product_qty']);
      double productPrice = double.parse(order['product_price']);
      return sum + (quantity * productPrice);
    });

    return grandTotal;
  }

  // This is for Adding the Bill
  Future<void> addToBill() async {
    // Prepare data for the API request
    int tableNo = widget.tableNumber;

    DateTime now = DateTime.now();
    String orderDate = '${now.year}-${now.month}-${now.day}';
    String orderTime = '${now.hour}:${now.minute}:${now.second}';

    List<Map<String, dynamic>> ordersForTable = orderData
        .where((order) =>
            order['order_table'] == tableNo.toString() &&
            order['order_status'] == 'In Process')
        .toList();
    final latestInvoiceId = await fetchLatestInvoiceId();
    print('Latest Invoice ID: $latestInvoiceId');
    double grandTotal = calculateGrandTotal(ordersForTable);

    // Loop through the orders and make API request for each
    for (var order in ordersForTable) {
      String itemName = order['product_name'];
      double itemPrice = double.parse(order['product_price']);
      int qty = int.parse(order['product_qty']);
      double itemAmt = double.parse(order['product_amount']);

      final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=addinv';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'inv_id': latestInvoiceId,
          'inv_date': orderDate,
          'table_no': tableNo.toString(),
          'item_name': itemName,
          'item_price': itemPrice.toString(),
          'qty': qty.toString(),
          'item_amt': itemAmt.toString(),
          'bill_amt': grandTotal.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Successful addition to bill
        print('Item added to bill successfully: $itemName');
        // print('Item added to bill successfully: $orderDate');
        print(response.body);
      } else {
        // Handle error
        print('Failed to add item to bill: ${response.statusCode}');
      }
      Fluttertoast.showToast(
          msg: 'Item added to bill successfully: $itemName',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    showBillItemsPopup(ordersForTable, grandTotal, latestInvoiceId);

    // Optionally, you can clear the orders from the table after adding to the bill
    // This depends on your specific use case
    // clearOrdersFromTable();
  }

  // This code is for getting the lettest InvoiceId fro the api to pass into AddToBill
  Future<String> fetchLatestInvoiceId() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readid';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      return response.body.trim();
    } else {
      throw Exception('Failed to fetch latest invoice ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    const double defaultPadding = 16.0;
    const double defaultMargin = 16.0;

    double responsivePadding = screenWidth * 0.05;
    double responsiveMargin = screenWidth * 0.05;
    double responsiveFontSize = screenWidth * 0.04;
    double containerWidth = screenWidth * 0.8;
    double containerHeight = screenHeight * 0.3;

    List<Map<String, dynamic>> ordersForTable = orderData
        .where((order) =>
            order['order_table'] == widget.tableNumber.toString() &&
            order['order_status'] == 'In Process')
        .toList();

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press here
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        // Navigator.pop(context);
        return false; // Return false to prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Menu List - Table ${widget.tableNumber}'),
        ),
        // drawer: CustomDrawer(onItemSelected: addItemToTable),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        // Dropdown for selecting products
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: selectedProduct,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedProduct = newValue;
                                  updateTotal(); // Update the total when the product changes
                                });
                              },
                              hint: const Text('Select an item'),
                              // Add this line
                              items: products.map((product) {
                                return DropdownMenuItem<String>(
                                  value: product['product_name'],
                                  child: Text(product['product_name']),
                                );
                              }).toList(),
                            ),
                            SizedBox(width: responsivePadding),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      decrementQuantity();
                                      updateTotal(); // Update the total when the quantity decreases
                                    },
                                    iconSize: responsiveFontSize,
                                  ),
                                  Text('$selectedQuantity',
                                      style: TextStyle(
                                          fontSize: responsiveFontSize)),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      incrementQuantity();
                                      updateTotal(); // Update the total when the quantity increases
                                    },
                                    iconSize: responsiveFontSize,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: responsivePadding),
                        Container(
                          height: screenHeight * 0.07,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              ' Total: $totalAmount ',
                              // Display the total amount
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveFontSize),
                            ),
                          ),
                        ),
                        SizedBox(height: responsivePadding),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: containerWidth,
                              child: ElevatedButton(
                                onPressed: addItemToOrder,
                                child: Text('Add Item',
                                    style: TextStyle(
                                        fontSize: responsiveFontSize)),
                                style: ButtonStyle(
                                    // backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 10),
                        //
                        // Container(
                        //   height: 1.0, // Adjust the height of the border
                        //   width: screenWidth - 20, // Adjust the width of the border
                        //   color: Colors.black, // Adjust the color of the border
                        // ),

                        const SizedBox(height: 20),

                        ordersForTable.isNotEmpty
                            ? SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'Date: ${getFormattedDate()}',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      'Orders for Table ${widget.tableNumber}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Table(
                                      defaultColumnWidth:
                                          const IntrinsicColumnWidth(),
                                      border: TableBorder.all(),
                                      children: [
                                        const TableRow(
                                          children: [
                                            TableCell(
                                                child: Center(
                                                    child: Text(' Sr \n No.'))),
                                            TableCell(
                                                child: Center(
                                                    child:
                                                        Text(' Item \nName '))),
                                            TableCell(
                                                child: Center(
                                                    child: Text(' Quantity '))),
                                            TableCell(
                                                child: Center(
                                                    child: Text(' Price '))),
                                            TableCell(
                                                child: Center(
                                                    child: Text(' Total '))),
                                            TableCell(
                                                child: Center(
                                                    child: Text('Remove '))),
                                          ],
                                        ),
                                        for (int i = 0;
                                            i < ordersForTable.length;
                                            i++)
                                          buildOrderTableRow(
                                              i + 1, ordersForTable[i]),
                                        buildGrandTotalDisplay(
                                            widget.tableNumber)
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const Center(child: Text('Add your order.')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // placeOrder();
                // addItnvocie();
                addToBill();
              },
              child: const Text('Print Bill'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     // Place order button pressed
            //     // placeOrder();
            //     completeOrder(
            //       widget.tableNumber.toString(),
            //     );
            //   },
            //   child: const Text('Complete Order'),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> showBillItemsPopup(List<Map<String, dynamic>> billItems,
      double grandTotal, String invId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Hotel Bill')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Inv ID: $invId',
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10,),
                Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(child: Center(child: Text(' Sr \n No '))),
                        TableCell(child: Center(child: Text(' Item \nName '))),
                        TableCell(child: Center(child: Text(' Quantity '))),
                        TableCell(child: Center(child: Text(' Price '))),
                        TableCell(child: Center(child: Text(' Total '))),
                        // Add more cells or headers as needed
                      ],
                    ),
                    for (int i = 0; i < billItems.length; i++)
                      buildBillItemTableRow(i + 1, billItems[i]),
                    buildGrandTotalTableRow(billItems.length + 1, grandTotal),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set your desired background color
                    borderRadius: BorderRadius.circular(8.0), // Set border radius
                  ),
                  child: TextButton(
                    onPressed: () {
                      _printData(invId);
                    },

                    child: Text(
                      'Print',
                      style: TextStyle(
                        color: Colors.white, // Set your desired text color
                        fontSize: 16.0,
                      ),

                    ),

                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  TableRow buildBillItemTableRow(
      int serialNumber, Map<String, dynamic> billItem) {
    String itemName = billItem['product_name'];
    int quantity = int.parse(billItem['product_qty']);
    double price = double.parse(billItem['product_price']);
    double total = double.parse(billItem['product_amount']);

    return TableRow(
      children: [
        TableCell(child: Center(child: Text(serialNumber.toString()))),
        TableCell(child: Center(child: Text(" ${itemName} "))),
        TableCell(child: Center(child: Text(" ${quantity.toString()} "))),
        TableCell(child: Center(child: Text(" ${price.toStringAsFixed(2)} "))),
        TableCell(child: Center(child: Text(" ${total.toStringAsFixed(2)} "))),
      ],
    );
  }

  TableRow buildGrandTotalTableRow(int serialNumber, double grandTotal) {
    return TableRow(
      children: [
        TableCell(child: SizedBox()), // Empty cell for spacing
        TableCell(child: SizedBox()),
        TableCell(child: SizedBox()),
        TableCell(child: Center(child: Text('Grand Total:'))),
        TableCell(
          child: Center(child: Text(' ${grandTotal.toStringAsFixed(2)} ')),
        ),
      ],
    );
  }
  // This api for reading and printing  the items of Bill.
  Future<List<Map<String, dynamic>>> fetchTableData(String invId) async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readinv';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'inv_id': invId},
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        final List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> tableData = [];
        for (var item in data) {
          tableData.add(Map<String, dynamic>.from(item));
        }
        return tableData;
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching table data: $error');
      throw error;
    }
  }

  // Here we print the Bill
  Future<void> _printData(String invId) async {
    try {
      // Assuming you have fetched the table data in the widget's state
      var tableData = await fetchTableData(invId);

      // Connect to Bluetooth printer
      await _connectToBluetoothPrinter();

      // Replace the following lines with your actual Bluetooth printer details
      String printerName = "BlueTooth Printer";
      String printerAddress = "DC:0D:30:CA:34:E6";

      BluetoothDevice device = BluetoothDevice();
      device.name = printerName;
      device.address = printerAddress;

      print('Selected Bluetooth Device: ${device.name ?? 'Unknown'}');

      if (await bluetoothPrint.isConnected == true) {
        print('Already connected to ${device.name}');
      } else {
        await bluetoothPrint.connect(device);

        if (bluetoothPrint.state == BluetoothPrint.CONNECTED) {
          print('Connected to ${device.name} successfully.');
        } else {
          print('Connection failed. State: ${bluetoothPrint.state}');
          return;
        }
      }

      Map<String, dynamic> config = Map();
      List<LineText> list = [];
      // list.add(LineText(
      //   type: LineText.TYPE_TEXT,
      //   content: "----------------------------------------", // Empty content for space
      //   width: 2, // Adjust this value to control the amount of space on the left
      //   linefeed: 1,
      // ));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Hotel Bill',
          weight: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "", // Empty content for space
        width: 2, // Adjust this value to control the amount of space on the left
        linefeed: 1,
      ));
      // Print Invoice ID
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Bill No: $invId',
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
      // Print Invoice Date
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Date: ${tableData.isNotEmpty ? tableData[0]['inv_date'] : ''}',
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "", // Empty content for space
        width: 2, // Adjust this value to control the amount of space on the left
        linefeed: 1,
      ));

      for (var index = 0; index < tableData.length; index++) {
        var item = tableData[index];
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: '${index + 1}. ${item['item_name']}',
            width: 0,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));

        list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "${item['item_price']} X ${item['qty']} =  ${item['item_amt']}", // Concatenate both pieces of content
          align: LineText.ALIGN_LEFT,
          linefeed: 1,
        ));

// Add an indented LineText for space on the left
        list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "", // Empty content for space
          width: 2, // Adjust this value to control the amount of space on the left
          linefeed: 1,
        ));
      }

      double totalBillAmount = 0;

      // Calculate total bill amount
      for (var item in tableData) {
        totalBillAmount += double.parse(item['item_amt']);
      }

      list.add((LineText(
        type: LineText.TYPE_TEXT,
        content: "Total: ${totalBillAmount.toStringAsFixed(2)}",
        align: LineText.ALIGN_RIGHT,
        linefeed: 1,
      )));

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "----------------------------------------", // Empty content for space
        width: 2, // Adjust this value to control the amount of space on the left
        linefeed: 1,
      ));

      await bluetoothPrint.printReceipt(config, list);

      print('Bluetooth Result is:${bluetoothPrint.state}');

      completeOrder(
        widget.tableNumber.toString(),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => HomeScreen(
      //       mobileNumber: widget.mobileNumber,
      //       // latestInvoiceId: submittedInvoiceId
      //     ),
      //   ),
      // );
    } catch (e, stackTrace) {
      print('Printing error: $e');
      print('Stack trace: $stackTrace');
    }
  }


//   void placeOrder() async {
//     DateTime now = DateTime.now();
//     String orderDate = '${now.year}-${now.month}-${now.day}';
//     String orderTime = '${now.hour}:${now.minute}:${now.second}';
//
//     double grandTotal = _selectedItems.fold(0.0, (sum, item) {
//       return sum + (item['quantity'] * double.parse(item['itemPrice']));
//     });
//
//
//     // Create a copy of the selected items list
//
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=addorder';
//
//     // Create a copy of the selected items list
//     List<Map<String, dynamic>> selectedItemsCopy = List.from(_selectedItems);
// // Print the list before making the API request
//     print('Selected Items List:');
//     for (var item in selectedItemsCopy) {
//       print(item);
//     }
//     for (var item in selectedItemsCopy) {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {
//           'product_name': item['itemName'],
//           'product_qty': item['quantity'].toString(),
//           'product_price': item['itemPrice'].toString(),
//           'product_amount': (item['quantity'] * double.parse(item['itemPrice'])).toString(),
//           'order_number': '20',
//           'order_table': widget.tableNumber.toString(),
//           'order_date': orderDate,
//           'order_time': orderTime,
//         }..removeWhere((key, value) => value == null),
//       );
//
//       print('API Response: ${response.statusCode}');
//       print('API Body : ${response.body}');
//
//       if (response.body == "Order Added Successfully.") {
//         final snackBar = SnackBar(
//           content: Text(
//             'Item ${item['itemName']} added to Cart.',
//             textAlign: TextAlign.center,
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       } else {
//         print(' ${response.body}');
//       }
//     }
//     fetchData();
//     buildGrandTotalDisplay(widget.tableNumber);
//     // Clear the selected items after placing the order
//     setState(() {
//       _selectedItems.clear();
//     });
//   }
}
