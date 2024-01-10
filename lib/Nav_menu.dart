// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class CustomDrawer extends StatelessWidget {
//   final Function(String, String) onItemSelected; // Update the function type
//
//   CustomDrawer({required this.onItemSelected});
//
//   Future<List<Map<String, dynamic>>> fetchMenuItems() async {
//     final response = await http.get(
//       Uri.parse("https://trifrnd.in/api/inv.php?apicall=readproducts"),
//     );
//
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.cast<Map<String, dynamic>>();
//     } else {
//       throw Exception('Failed to load menu items');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: fetchMenuItems(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Text('No menu items available');
//         } else {
//           List<Map<String, dynamic>> menuItems = snapshot.data!;
//           return Drawer(
//             child: ListView(
//               children: [
//                 DrawerHeader(
//                   decoration: BoxDecoration(
//                     color: Colors.blue,
//                   ),
//                   child: Text(
//                     'Menu Items',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                     ),
//                   ),
//                 ),
//                 for (var item in menuItems)
//                   buildDrawerItem(item['product_name'], item['product_price'], context),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
//
//   Widget buildDrawerItem(String itemName, String itemPrice, BuildContext context) {
//     return ListTile(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(itemName, style: TextStyle(fontSize: 16)),
//           Text(itemPrice, style: TextStyle(fontSize: 14)),
//         ],
//       ),
//       onTap: () {
//         onItemSelected(itemName, itemPrice); // Pass both itemName and itemPrice
//
//         // onItemSelected('$itemName - ${double.parse(itemPrice).toStringAsFixed(2)}');
//         Navigator.pop(context); // Close the drawer
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Login_Screen.dart';

class NavBar extends StatefulWidget {
  final String mobileNumber;

  NavBar({required this.mobileNumber});

  @override
  State<NavBar> createState() => _NavBarState();
}
class _NavBarState extends State<NavBar> {
  late Map<String, dynamic> userData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userData = {};
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: buildDrawer(),
    );
  }

  Widget buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Colors.white60,
          height: 190,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/image/img.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              // Positioned(
              //   top: 79.0,
              //   left: 8.0,
              //   child: ConstrainedBox(
              //     constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
              //     child: GestureDetector(
              //       onTap: () {
              //         showDialog(
              //           context: context,
              //           builder: (context) {
              //             return Dialog(
              //               backgroundColor: Colors.transparent,
              //               child: Stack(
              //                 children: [
              //                   Column(
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       // Image.network(
              //                       //   userData['userImage'],
              //                       //   width: 200,
              //                       //   height: 200,
              //                       // ),
              //                     ],
              //                   ),
              //                   Positioned(
              //                     bottom: 170,
              //                     right: 50.0,
              //                     child: IconButton(
              //                       icon: Icon(
              //                         Icons.close,
              //                         color: Colors.black,
              //                       ),
              //                       onPressed: () {
              //                         Navigator.of(context).pop();
              //                       },
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             );
              //           },
              //         );
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        ListTile(
          title:
          Container(
            width: 50.0,
            height: 100.0,
            child: Image.network(
              'https://apip.trifrnd.com/fruits/${userData['userImage']}',
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: Colors.white70,
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                );
              },
            ),
          ),
        ),
        ListTile(
          title: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Name: ${userData?['username']}" ?? '',style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Email: ${userData?['email']}" ?? ''),
                Text("Mobile: ${widget.mobileNumber}"),
                Text("Gender: ${userData?['gender']}" ?? ''),
              ],
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.report_gmailerrorred),
          title: Text("Report"),
          onTap: () {
            // Handle tap
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text("Log Out"),
          onTap: () async {
            // Handle tap
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  // latestInvoiceId: submittedInvoiceId
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final apiUrl = 'https://apip.trifrnd.com/Fruits/inv.php?apicall=profile';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'mobile': widget.mobileNumber},
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
        });
      } else {
        print('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
