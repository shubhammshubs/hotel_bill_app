// import 'dart:convert';
//
// import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
//
// import 'Home_Screen.dart';
//
// class DisplayTableDataPage extends StatefulWidget {
//   final int tableNumber;
//
//   DisplayTableDataPage({required this.tableNumber});
//
//   @override
//   _DisplayTableDataPageState createState() => _DisplayTableDataPageState();
// }
//
// class _DisplayTableDataPageState extends State<DisplayTableDataPage> {
//   List<Map<String, dynamic>> orderData = [];
//   bool _loading = false;
//   List<Map<String, dynamic>> ordersForTable = []; // Define ordersForTable
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//
//   }
//
//
//
//
//
//
//
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
//   Future<void> removeProduct(
//       String orderTable,
//       String productName,
//       String productQty,
//       String productPrice,
//       String productAmount,
//       ) async {
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=remprod';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         'order_table': orderTable,
//         'product_name': productName,
//         'product_qty': productQty,
//         'product_price': productPrice,
//         'product_amount': productAmount,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       // Successful removal
//       print('Product removed successfully');
// // Reload the page by fetching the updated data
//       fetchData();
//       // Optionally, you can refresh the table or update the UI as needed.
//     } else {
//       // Handle error
//       print('Failed to remove product: ${response.statusCode}');
//     }
//   }
//
//   Future<void> completeOrder(
//       String orderTable,
//       ) async {
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=updateord';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         'order_table': orderTable,
//       },
//     );
//     if (response.statusCode == 200) {
//       // Successful removal
//       print('Product Completed successfully ${orderTable}');
// // Reload the page by fetching the updated data
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context)=>
//               HomePage()
//           ));
//
//       // Optionally, you can refresh the table or update the UI as needed.
//     } else {
//       // Handle error
//       print('Failed to Complete product: ${response.statusCode}');
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     ordersForTable = orderData
//         .where((order) =>
//     order['order_table'] == widget.tableNumber.toString() &&
//         order['order_status'] == 'In Process')
//         .toList();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Table ${widget.tableNumber} Data'),
//       ),
//       body: ordersForTable.isNotEmpty
//           ? buildTable(ordersForTable)
//           : Center(
//         child: Text('No data available for Table ${widget.tableNumber}'),
//       ),
//     );
//   }
//
//   Widget buildTable(List<Map<String, dynamic>> orders) {
//     String getFormattedDate() {
//       DateTime now = DateTime.now();
//       String formattedDate = '${now.day}-${now.month}-${now.year}';
//       print(formattedDate);
//       return formattedDate;
//     }
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     const double defaultPadding = 16.0;
//     const double defaultMargin = 16.0;
//
//     double responsivePadding = screenWidth * 0.05;
//     double responsiveMargin = screenWidth * 0.05;
//     double responsiveFontSize = screenWidth * 0.04;
//     double containerWidth = screenWidth * 0.8;
//     double containerHeight = screenHeight * 0.3;
//
//
//     return Scaffold(
//
//       // drawer: CustomDrawer(onItemSelected: addItemToTable),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             SizedBox(width: 20,),
//             Column(
//               children: [
//                 SizedBox(width: 10),
//                 // buildDateText(),
//                 // Align(
//                 //   alignment: Alignment.topLeft,
//                 //   child: Text(
//                 //     'Date: ${getFormattedDate()}',
//                 //     style: TextStyle(fontSize: 18),
//                 //   ),
//                 // ),
//                 SizedBox(height: 10),
//                 Table(
//                   defaultColumnWidth: const IntrinsicColumnWidth(),
//                   border: TableBorder.all(),
//                   children: [
//                     TableRow(
//                       children: [
//                         TableCell(child: Text(' Sr.\n No. ')),
//                         TableCell(child: Center(child: Text(' Item \n Name '))),
//                         TableCell(child: Center(child: Text(' Price '))),
//                         TableCell(child: Center(child: Text(' Quantity '))),
//                         TableCell(child: Center(child: Text(' Total '))),
//                         TableCell(child: Center(child: Text(' Remove '))),
//                       ],
//                     ),
//                     for (int i = 0; i < orders.length; i++)
//                       TableRow(
//                         children: [
//                           TableCell(child: Center(child: Text('$i'))),
//                           TableCell(child: Center(child: Text( " ${orders[i]['product_name'] ?? 'N/A'} "))),
//                           TableCell(child: Center(child: Text(' ${orders[i]['product_price']?.toString() ?? 'N/A'} '))),
//                           TableCell(child: Center(child: Text(' ${orders[i]['product_qty'] ?? 0} '))),
//                           TableCell(child: Center(child: Text(' ${orders[i]['product_amount'] ?? 0} '))),
//                           TableCell(
//                             child: Center(
//                               child: InkWell(
//                                 onTap: () {
//
//
//                                   // removeItemFromTable(index);
//
//                                   removeProduct(
//                                     orders[i]['order_table'],
//                                     orders[i]['product_name'],
//                                     orders[i]['product_qty'],
//                                     orders[i]['product_price'],
//                                     orders[i]['product_amount'],
//                                   );
//
//                                 },
//                                 child: Icon(Icons.remove_circle),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: 20,),
//
//
//
//                 // SizedBox(height: 10),
//                 // buildGrandTotalRow(),
//               ],
//             ),
//           ],
//         ),
//       ),
//
//       bottomNavigationBar: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               // Place order button pressed
//               // placeOrder();
//               completeOrder(
//                 widget.tableNumber.toString(),
//               );
//             },
//             child: Text('Complete Order'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Cancel button pressed
//               // Navigator.pop(context); // Close the MenuListPage
//               Navigator.pushReplacement(context,
//                   MaterialPageRoute(builder: (context)=>
//                       HomePage()
//                   ));
//             },
//             child: Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//
//
//   }
// }
//
// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:waiter_bill_app/Home_Screen.dart';
// // import 'DisplayTableDataPage.dart';
// // import 'Nav_menu.dart';
// //
// // class MenuListPage extends StatefulWidget {
// //   final int tableNumber;
// //
// //   MenuListPage({required this.tableNumber});
// //
// //   @override
// //   _MenuListPageState createState() => _MenuListPageState();
// // }
// //
// // class _MenuListPageState extends State<MenuListPage> {
// //   List<Map<String, dynamic>> _selectedItems = [];
// //   List<Map<String, dynamic>> _items = [];
// //   List<Map<String, dynamic>> responseData = [];
// //   Map<String, int> itemQuantities = {};
// //   String selectedItemId = "";
// //   int selectedQuantity = 1;
// //   String submittedInvoiceId = ""; // Add this line
// //   int _serialNumber = 1; // Add this line
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //   bool _isLoading = false;
// //   String? selectedProduct; // New variable to store the selected product
// //   List<Map<String, dynamic>> products = []; // List to store products from API
// //   List<Map<String, dynamic>> orderData = []; // Add this line
// //
// //
// //   void initState() {
// //     super.initState();
// //     // Fetch products from API when the widget is initialized
// //     fetchProducts();
// //     fetchData(); // Fetch order data when the widget is initialized
// //
// //   }
// //   Future<void> fetchData() async {
// //     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readorders';
// //     final response = await http.get(Uri.parse(apiUrl));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> data = jsonDecode(response.body);
// //       setState(() {
// //         orderData = List.from(data);
// //       });
// //     } else {
// //       // Handle error
// //       print('Failed to load data: ${response.statusCode}');
// //     }
// //   }
// //
// //   Future<void> fetchProducts() async {
// //     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readproducts';
// //     final response = await http.get(Uri.parse(apiUrl));
// //
// //     if (response.statusCode == 200) {
// //       setState(() {
// //         products = List<Map<String, dynamic>>.from(
// //           json.decode(response.body) as List<dynamic>,
// //         );
// //       });
// //     } else {
// //       print('Failed to load products. Error: ${response.statusCode}');
// //     }
// //   }
// //
// //   String getFormattedDate() {
// //     DateTime now = DateTime.now();
// //     String formattedDate = '${now.day}-${now.month}-${now.year}';
// //     print(formattedDate);
// //
// //     return formattedDate;
// //   }
// //
// //   void incrementQuantity() {
// //     setState(() {
// //       selectedQuantity++;
// //     });
// //   }
// //
// //   void decrementQuantity() {
// //     if (selectedQuantity > 1) {
// //       setState(() {
// //         selectedQuantity--;
// //       });
// //     }
// //   }
// //   Future<void> removeProduct(
// //       String orderTable,
// //       String productName,
// //       String productQty,
// //       String productPrice,
// //       String productAmount,
// //       ) async {
// //     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=remprod';
// //     final response = await http.post(
// //       Uri.parse(apiUrl),
// //       body: {
// //         'order_table': orderTable,
// //         'product_name': productName,
// //         'product_qty': productQty,
// //         'product_price': productPrice,
// //         'product_amount': productAmount,
// //       },
// //     );
// //
// //     if (response.statusCode == 200) {
// //       // Successful removal
// //       print('Product removed successfully');
// // // Reload the page by fetching the updated data
// //       fetchData();
// //       // Optionally, you can refresh the table or update the UI as needed.
// //     } else {
// //       // Handle error
// //       print('Failed to remove product: ${response.statusCode}');
// //     }
// //   }
// //
// //
// //   // Add this method in your _MenuListPageState class
// //   // TableRow buildOrderTableRow(Map<String, dynamic> order) {
// //   //   String productName = order['product_name'];
// //   //   int quantity = int.parse(order['product_qty']);
// //   //   double totalAmount = double.parse(order['product_amount']);
// //   //   double total = double.parse(order['product_price']);
// //   //
// //   //
// //   //   return TableRow(
// //   //     children: [
// //   //       TableCell(child: Center(child: Text(order['order_number'].toString()))),
// //   //       TableCell(child: Center(child: Text(productName))),
// //   //       TableCell(child: Center(child: Text(total.toStringAsFixed(2)))),
// //   //       TableCell(child: Center(child: Text(quantity.toString()))),
// //   //       TableCell(child: Center(child: Text(totalAmount.toStringAsFixed(2)))),
// //   //     ],
// //   //   );
// //   // }
// //   TableRow buildOrderTableRow(int serialNumber, Map<String, dynamic> order) {
// //     String productName = order['product_name'];
// //     int quantity = int.parse(order['product_qty']);
// //     double totalAmount = double.parse(order['product_amount']);
// //     double total = double.parse(order['product_price']);
// //
// //     return TableRow(
// //       children: [
// //         TableCell(child: Center(child: Text(serialNumber.toString()))),
// //         TableCell(child: Center(child: Text(productName))),
// //         TableCell(child: Center(child: Text(quantity.toString()))),
// //         TableCell(child: Center(child: Text(total.toStringAsFixed(2)))),
// //         TableCell(child: Center(child: Text(totalAmount.toStringAsFixed(2)))),
// //         TableCell(
// //           child: Center(
// //             child: IconButton(
// //               icon: Icon(Icons.remove_circle),
// //               onPressed: () {
// //                 // Add your logic to remove the product here
// //                 removeProduct(
// //                   order['order_table'].toString(),
// //                   productName,
// //                   quantity.toString(),
// //                   total.toString(),
// //                   totalAmount.toString(),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //   TableRow buildGrandTotalDisplay(int tableNumber) {
// //     List<Map<String, dynamic>> ordersForTable = orderData
// //         .where((order) =>
// //     order['order_table'] == tableNumber.toString() &&
// //         order['order_status'] == 'In Process')
// //         .toList();
// //
// //     double grandTotal = ordersForTable.fold(0.0, (sum, order) {
// //       double quantity = double.parse(order['product_qty']);
// //       double productPrice = double.parse(order['product_price']);
// //       return sum + (quantity * productPrice);
// //     });
// //
// //
// //     return TableRow(
// //       children: [
// //         TableCell(child: SizedBox()), // Empty cell for spacing
// //         TableCell(child: SizedBox()),
// //         TableCell(child: SizedBox()),
// //         TableCell(child: Center(child: Text('Grand Total:'))),
// //         TableCell(
// //           child: Center(child: Text(' ${grandTotal.toStringAsFixed(2)} ')),
// //         ),
// //         TableCell(child: SizedBox()), //
// //       ],
// //     );
// //   }
// //
// //   Future<void> completeOrder(
// //       String orderTable,
// //       ) async {
// //     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=updateord';
// //     final response = await http.post(
// //       Uri.parse(apiUrl),
// //       body: {
// //         'order_table': orderTable,
// //       },
// //     );
// //     if (response.statusCode == 200) {
// //       // Successful removal
// //       print('Product Completed successfully ${orderTable}');
// // // Reload the page by fetching the updated data
// //       Navigator.pushReplacement(context,
// //           MaterialPageRoute(builder: (context)=>
// //               HomePage()
// //           ));
// //
// //       // Optionally, you can refresh the table or update the UI as needed.
// //     } else {
// //       // Handle error
// //       print('Failed to Complete product: ${response.statusCode}');
// //     }
// //   }
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print('Products Count: ${products.length}'); // Add this line
// //
// //     List<Map<String, dynamic>> ordersForTable = orderData
// //         .where((order) =>
// //     order['order_table'] == widget.tableNumber.toString() &&
// //         order['order_status'] == 'In Process')
// //         .toList();
// //
// //     return WillPopScope(
// //       onWillPop: () async {
// //         // Handle back button press here
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (context) => HomePage()),
// //         );
// //         return false; // Return false to prevent default back button behavior
// //       },
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: Text('Menu List - Table ${widget.tableNumber}'),
// //         ),
// //         // drawer: CustomDrawer(onItemSelected: addItemToTable),
// //         body: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //
// //           child: Center(
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: Center(
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     SizedBox(width: 20,),
// //                     Column(
// //                       children: [
// //                         SizedBox(height: 10),
// //                         // Dropdown for selecting products
// //                         DropdownButton<String>(
// //                           value: selectedProduct,
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               selectedProduct = newValue;
// //                             });
// //                           },
// //                           hint: Text('Select an item'), // Add this line
// //                           items: products.map((product) {
// //                             return DropdownMenuItem<String>(
// //                               value: product['product_name'],
// //                               child: Text(product['product_name']),
// //                             );
// //                           }).toList(),
// //                         ),
// //                         // DropdownButton<String>(
// //                         //   value: selectedProduct,
// //                         //   onChanged: (String? newValue) {
// //                         //     print('Selected Product: $newValue'); // Debug statement
// //                         //     setState(() {
// //                         //       selectedProduct = newValue;
// //                         //       print('Updated selectedProduct: $selectedProduct'); // Debug statement
// //                         //
// //                         //       // Add the selected product to the table
// //                         //       if (selectedProduct != null) {
// //                         //         Map<String, dynamic>? selectedProductDetails = products
// //                         //             .firstWhere(
// //                         //                 (product) =>
// //                         //             product['product_name'] == selectedProduct);
// //                         //
// //                         //         if (selectedProductDetails != null) {
// //                         //           print('Adding to table: ${selectedProductDetails['product_name']}'); // Debug statement
// //                         //           addItemToTable(
// //                         //             selectedProductDetails['product_name'] as String,
// //                         //             selectedProductDetails['product_price'] as String,
// //                         //           );
// //                         //         } else {
// //                         //           print('Selected product not found in the list.');
// //                         //         }
// //                         //       }
// //                         //     });
// //                         //   },
// //                         //   hint: Text('Select an item'),
// //                         //   items: products.map((product) {
// //                         //     return DropdownMenuItem<String>(
// //                         //       value: product['product_name'],
// //                         //       child: Text(product['product_name']),
// //                         //     );
// //                         //   }).toList(),
// //                         // ),
// //
// //                         // Button to add the selected product
// //                         SizedBox(height: 10),
// //                         // ElevatedButton(
// //                         //   onPressed: () {
// //                         //     if (selectedProduct != null) {
// //                         //       // Find the selected product details from the products list
// //                         //       Map<String, dynamic>? selectedProductDetails = products
// //                         //           .firstWhere(
// //                         //               (product) =>
// //                         //           product['product_name'] == selectedProduct);
// //                         //
// //                         //       if (selectedProductDetails != null) {
// //                         //         // Add the selected product to the table
// //                         //         addItemToTable(
// //                         //           selectedProductDetails['product_name'] as String,
// //                         //           selectedProductDetails['product_price'] as String,
// //                         //         );
// //                         //       } else {
// //                         //         // Handle the case when the selected product is not found
// //                         //         print('Selected product not found in the list.');
// //                         //         // Optionally, show a message in the UI
// //                         //         // You can add your own logic or UI feedback here
// //                         //       }
// //                         //     }
// //                         //   },
// //                         //   child: Text('Add Item'),
// //                         // ),
// //                         SizedBox(width: 10),
// //                         Align(
// //                           alignment: Alignment.topLeft,
// //                           child: Text(
// //                             'Date: ${getFormattedDate()}',
// //                             style: TextStyle(fontSize: 18),
// //                           ),
// //                         ),
// //                         SizedBox(height: 10),
// //                         Table(
// //                           defaultColumnWidth: const IntrinsicColumnWidth(),
// //                           border: TableBorder.all(),
// //                           children: [
// //                             TableRow(
// //                               children: [
// //                                 TableCell(child: Text('Sr.\nNo.')),
// //                                 TableCell(child: Center(child: Text('Item\nName'))),
// //                                 TableCell(child: Center(child: Text('Price'))),
// //                                 TableCell(child: Center(child: Text('Quantity'))),
// //                                 TableCell(child: Center(child: Text('Total'))),
// //                                 TableCell(child: Center(child: Text('Remove'))),
// //                               ],
// //                             ),
// //                             for (int i = 0; i < _selectedItems.length; i++)
// //                               buildTableRow(i),
// //                             buildGrandTotalRow(), // Include grand total row
// //                           ],
// //                         ),
// //                         // Grand total row
// //                         SizedBox(height: 20),
// //                         Text(
// //                           'Orders for Table ${widget.tableNumber}',
// //                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                         ),
// //
// //                 ordersForTable.isNotEmpty
// //                     ? Table(
// //                   defaultColumnWidth: const IntrinsicColumnWidth(),
// //                   border: TableBorder.all(),
// //                   children: [
// //                     TableRow(
// //                       children: [
// //                         TableCell(child: Center(child: Text('Sr\nNo.'))),
// //                         TableCell(child: Center(child: Text('Item\nName'))),
// //                         TableCell(child: Center(child: Text('Quantity'))),
// //                         TableCell(child: Center(child: Text('Price'))),
// //                         TableCell(child: Center(child: Text('Total'))),
// //                         TableCell(child: Center(child: Text('Remove'))),
// //                       ],
// //                     ),
// //                     for (int i = 0; i < ordersForTable.length; i++)
// //                       buildOrderTableRow(i + 1, ordersForTable[i]),
// //                     buildGrandTotalDisplay(widget.tableNumber)
// //
// //                   ],
// //                 )
// //                     : Text('No orders available for this table.'),
// //
// //
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //         bottomNavigationBar: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //           children: [
// //             ElevatedButton(
// //               onPressed: () {
// //                 // Place order button pressed
// //                 placeOrder();
// //               },
// //               child: Text('Place Order'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 // Place order button pressed
// //                 // placeOrder();
// //                 completeOrder(
// //                   widget.tableNumber.toString(),
// //                 );
// //               },
// //               child: Text('Complete Order'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   TableRow buildTableRow(int index) {
// //     String itemName = _selectedItems[index]['itemName'];
// //     double itemPrice = double.parse(_selectedItems[index]['itemPrice']);
// //     int quantity = _selectedItems[index]['quantity'];
// //     double total = itemPrice * quantity;
// //
// //     return TableRow(
// //       children: [
// //         TableCell(child: Center(child: Text((index + 1).toString()))),
// //         TableCell(child: Center(child: Text(itemName))),
// //         TableCell(
// //             child: Center(child: Text(' ${itemPrice.toStringAsFixed(2)} '))),
// //         TableCell(child: Center(child: buildQuantityRow(index))),
// //         TableCell(child: Center(child: Text(' ${total.toStringAsFixed(2)} '))),
// //         TableCell(
// //           child: Center(
// //             child: InkWell(
// //               onTap: () {
// //                 // Remove item from the table
// //                 removeItemFromTable(index);
// //               },
// //               child: Icon(Icons.remove_circle),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget buildQuantityRow(int index) {
// //     int quantity = _selectedItems[index]['quantity'];
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         IconButton(
// //           icon: Icon(Icons.remove),
// //           onPressed: () {
// //             updateQuantity(index, quantity - 1);
// //           },
// //         ),
// //         Text(quantity.toString()),
// //         IconButton(
// //           icon: Icon(Icons.add),
// //           onPressed: () {
// //             updateQuantity(index, quantity + 1);
// //           },
// //         ),
// //       ],
// //     );
// //   }
// //
// //   TableRow buildGrandTotalRow() {
// //     double grandTotal = _selectedItems.fold(0.0, (sum, item) {
// //       return sum + (item['quantity'] * double.parse(item['itemPrice']));
// //     });
// //
// //     return TableRow(
// //       children: [
// //         TableCell(child: SizedBox()), // Empty cell for spacing
// //         TableCell(child: SizedBox()),
// //         TableCell(child: SizedBox()),
// //         TableCell(child: Center(child: Text('Grand Total:'))),
// //         TableCell(
// //             child: Center(child: Text(' ${grandTotal.toStringAsFixed(2)} '))),
// //         TableCell(child: SizedBox()), // Empty cell for spacing
// //       ],
// //     );
// //   }
// //
// //   void addItemToTable(String itemName, String itemPrice) {
// //     Map<String, dynamic> selectedProduct = {
// //       'itemName': itemName,
// //       'itemPrice': itemPrice,
// //       'quantity': 1,
// //     };
// //     setState(() {
// //       _selectedItems.add(selectedProduct);
// //     });
// //   }
// //   void removeItemFromTable(int index) {
// //     setState(() {
// //       _selectedItems.removeAt(index);
// //     });
// //   }
// //
// //   void updateQuantity(int index, int newQuantity) {
// //     setState(() {
// //       _selectedItems[index]['quantity'] = newQuantity;
// //     });
// //   }
// //
// //   void placeOrder() async {
// //     DateTime now = DateTime.now();
// //     String orderDate = '${now.year}-${now.month}-${now.day}';
// //     String orderTime = '${now.hour}:${now.minute}:${now.second}';
// //
// //     double grandTotal = _selectedItems.fold(0.0, (sum, item) {
// //       return sum + (item['quantity'] * double.parse(item['itemPrice']));
// //     });
// //
// //
// //     // Create a copy of the selected items list
// //
// //     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=addorder';
// //
// //     // Create a copy of the selected items list
// //     List<Map<String, dynamic>> selectedItemsCopy = List.from(_selectedItems);
// // // Print the list before making the API request
// //     print('Selected Items List:');
// //     for (var item in selectedItemsCopy) {
// //       print(item);
// //     }
// //     for (var item in selectedItemsCopy) {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
// //         body: {
// //           'product_name': item['itemName'],
// //           'product_qty': item['quantity'].toString(),
// //           'product_price': item['itemPrice'].toString(),
// //           'product_amount': (item['quantity'] * double.parse(item['itemPrice'])).toString(),
// //           'order_number': '20',
// //           'order_table': widget.tableNumber.toString(),
// //           'order_date': orderDate,
// //           'order_time': orderTime,
// //         }..removeWhere((key, value) => value == null),
// //       );
// //
// //       print('API Response: ${response.statusCode}');
// //       print('API Body : ${response.body}');
// //
// //       if (response.body == "Order Added Successfully.") {
// //         final snackBar = SnackBar(
// //           content: Text(
// //             'Item ${item['itemName']} added to Cart.',
// //             textAlign: TextAlign.center,
// //           ),
// //         );
// //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
// //       } else {
// //         print(' ${response.body}');
// //       }
// //     }
// //     fetchData();
// //     buildGrandTotalDisplay(widget.tableNumber);
// //     // Clear the selected items after placing the order
// //     setState(() {
// //       _selectedItems.clear();
// //     });
// //   }
// // }
// //
// //
// //
