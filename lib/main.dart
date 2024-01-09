import 'package:flutter/material.dart';

import 'Home_Screen.dart';
import 'Login_Screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order App',
      home:
      LoginScreen(),
      // HomePage(),
    );
  }
}




// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:waiter_bill_app/Home_Screen.dart';
// import 'Nav_menu.dart';
//
// class MenuListPage extends StatefulWidget {
//   final int tableNumber;
//
//   MenuListPage({required this.tableNumber});
//
//   @override
//   _MenuListPageState createState() => _MenuListPageState();
// }
//
// class _MenuListPageState extends State<MenuListPage> {
//   List<Map<String, dynamic>> _selectedItems = [];
//   List<Map<String, dynamic>> orderData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
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
//   String getFormattedDate() {
//     DateTime now = DateTime.now();
//     String formattedDate = '${now.day}-${now.month}-${now.year}';
//     return formattedDate;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//       List<Map<String, dynamic>> ordersForTable = orderData
//           .where((order) =>
//       order['order_table'] == widget.tableNumber.toString() &&
//           order['order_status'] == 'In Process')
//           .toList();
//
//       bool isTableInProcess = ordersForTable.isNotEmpty &&
//           ordersForTable.any((order) => order['order_status'] == 'In Process');
//
//
//
//       return Scaffold(
//       appBar: AppBar(
//         title: Text('Menu List - Table ${widget.tableNumber}'),
//       ),
//       drawer: CustomDrawer(onItemSelected: addItemToTable),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             SizedBox(width: 20,),
//             Column(
//               children: [
//                 SizedBox(width: 10),
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: Text(
//                     'Date: ${getFormattedDate()}',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Table(
//                   defaultColumnWidth: const IntrinsicColumnWidth(),
//                   border: TableBorder.all(),
//                   children: [
//                     TableRow(
//                       children: [
//                         TableCell(child: Text('Sr.\nNo.')),
//                         TableCell(child: Center(child: Text('Item\nName'))),
//                         TableCell(child: Center(child: Text('Price'))),
//                         TableCell(child: Center(child: Text('Quantity'))),
//                         TableCell(child: Center(child: Text('Total'))),
//                         TableCell(child: Center(child: Text('Remove'))),
//                       ],
//                     ),
//                     if (isTableInProcess)
//                       for (int i = 0; i < ordersForTable.length; i++)
//                         buildTableRowFromOrder(i, ordersForTable[i], true),
//                     if (!isTableInProcess)
//                       for (int i = 0; i < _selectedItems.length; i++)
//                         buildTableRow(i, false),
//                     if (!isTableInProcess) buildGrandTotalRow(),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               // Place order button pressed
//               placeOrder();
//             },
//             child: Text('Place Order'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Cancel button pressed
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomePage(),
//                 ),
//               );
//             },
//             child: Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   TableRow buildTableRowFromOrder(int index, Map<String, dynamic> order, bool isRemoveVisible) {
//     String itemName = order['product_name'];
//     double itemPrice = double.parse(order['product_price']);
//     int quantity = int.parse(order['product_qty']);
//     double total = itemPrice * quantity;
//
//     return TableRow(
//       children: [
//         TableCell(child: Center(child: Text((index + 1).toString()))),
//         TableCell(child: Center(child: Text(itemName))),
//         TableCell(child: Center(child: Text(' ${itemPrice.toStringAsFixed(2)} '))),
//         TableCell(child: Center(child: buildQuantityRow(index, quantity))),
//         TableCell(child: Center(child: Text(' ${total.toStringAsFixed(2)} '))),
//         TableCell(
//           child: Center(
//             child: isRemoveVisible
//                 ? InkWell(
//               onTap: () {
//                 removeItemFromTableAndAPI(index, order);
//               },
//               child: Icon(Icons.remove_circle),
//             )
//                 : SizedBox(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   TableRow buildTableRow(int index, bool isRemoveVisible) {
//     String itemName = _selectedItems[index]['itemName'];
//     double itemPrice = double.parse(_selectedItems[index]['itemPrice']);
//     int quantity = _selectedItems[index]['quantity'];
//     double total = itemPrice * quantity;
//
//     return TableRow(
//       children: [
//         TableCell(child: Center(child: Text((index + 1).toString()))),
//         TableCell(child: Center(child: Text(itemName))),
//         TableCell(child: Center(child: Text(' ${itemPrice.toStringAsFixed(2)} '))),
//         TableCell(child: Center(child: buildQuantityRow(index, quantity))),
//         TableCell(child: Center(child: Text(' ${total.toStringAsFixed(2)} '))),
//         TableCell(
//           child: Center(
//             child: isRemoveVisible
//                 ? InkWell(
//               onTap: () {
//                 removeItemFromTableAndAPI(index, null);
//               },
//               child: Icon(Icons.remove_circle),
//             )
//                 : SizedBox(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildQuantityRow(int index, int quantity) {
//     int quantity = _selectedItems.isNotEmpty && index < _selectedItems.length
//         ? _selectedItems[index]['quantity']
//         : 0;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(Icons.remove),
//           onPressed: () {
//             updateQuantity(index, quantity - 1);
//           },
//         ),
//         Text(quantity.toString()),
//         IconButton(
//           icon: Icon(Icons.add),
//           onPressed: () {
//             updateQuantity(index, quantity + 1);
//           },
//         ),
//       ],
//     );
//   }
//
//   TableRow buildGrandTotalRow() {
//     double grandTotal = _selectedItems.fold(0.0, (sum, item) {
//       return sum + (item['quantity'] * double.parse(item['itemPrice']));
//     });
//
//     return TableRow(
//       children: [
//         TableCell(child: SizedBox()), // Empty cell for spacing
//         TableCell(child: SizedBox()),
//         TableCell(child: SizedBox()),
//         TableCell(child: Center(child: Text('Grand Total:'))),
//         TableCell(
//             child: Center(child: Text(' ${grandTotal.toStringAsFixed(2)} '))),
//         TableCell(child: SizedBox()), // Empty cell for spacing
//       ],
//     );
//   }
//
//   void addItemToTable(String itemName, String itemPrice) {
//     Map<String, dynamic> selectedProduct = {
//       'itemName': itemName,
//       'itemPrice': itemPrice,
//       'quantity': 1,
//     };
//     setState(() {
//       _selectedItems.add(selectedProduct);
//     });
//   }
//   void removeItemFromTableAndAPI(int index, Map<String, dynamic>? order) async {
//     if (order != null) {
//       // Remove item from the API
//       final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=remprod';
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {
//           'order_table': order['order_table'],
//           'product_name': order['product_name'],
//           'product_qty': order['product_qty'],
//           'product_price': order['product_price'],
//           'product_amount': order['product_amount'],
//         }..removeWhere((key, value) => value == null),
//       );
//
//       print('Remove API Response: ${response.statusCode}');
//       print('Remove API Body : ${response.body}');
//
//       if (response.body == "Product Removed Successfully.") {
//         final snackBar = SnackBar(
//           content: Text(
//             'Item ${order['product_name']} removed from the table and API.',
//             textAlign: TextAlign.center,
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//
//         // Refresh the UI after removing the item
//         fetchData();
//       } else {
//         print('Remove API Error: ${response.body}');
//       }
//     }
//
//     // Remove item from the local table
//     removeItemFromTable(index);
//   }
//
//
//
//   void removeItemFromTable(int index) {
//     setState(() {
//       _selectedItems.removeAt(index);
//     });
//   }
//
//   void updateQuantity(int index, int newQuantity) {
//     setState(() {
//       _selectedItems[index]['quantity'] = newQuantity;
//     });
//   }
//
//   void placeOrder() async {
//     DateTime now = DateTime.now();
//     String orderDate = '${now.year}-${now.month}-${now.day}';
//     String orderTime = '${now.hour}:${now.minute}:${now.second}';
//
//     double grandTotal = _selectedItems.fold(0.0, (sum, item) {
//       return sum + (item['quantity'] * double.parse(item['itemPrice']));
//     });
//
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=addorder';
//
//     List<Map<String, dynamic>> selectedItemsCopy = List.from(_selectedItems);
//
//     for (var item in selectedItemsCopy) {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {
//           'product_name': item['itemName'],
//           'product_qty': item['quantity'].toString(),
//           'product_price': double.parse(item['itemPrice']).toString(),
//           'product_amount': (item['quantity'] * double.parse(item['itemPrice'])).toString(),
//           // 'product_price': (item['quantity'] * double.parse(item['itemPrice'])).toString(),
//           // 'product_amount': grandTotal.toString(),
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
//
//     setState(() {
//       _selectedItems.clear();
//     });
//   }
// }
