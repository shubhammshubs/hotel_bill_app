import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomDrawer extends StatelessWidget {
  final Function(String, String) onItemSelected; // Update the function type

  CustomDrawer({required this.onItemSelected});

  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    final response = await http.get(
      Uri.parse("https://trifrnd.in/api/inv.php?apicall=readproducts"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMenuItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No menu items available');
        } else {
          List<Map<String, dynamic>> menuItems = snapshot.data!;
          return Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Menu Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                for (var item in menuItems)
                  buildDrawerItem(item['product_name'], item['product_price'], context),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildDrawerItem(String itemName, String itemPrice, BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(itemName, style: TextStyle(fontSize: 16)),
          Text(itemPrice, style: TextStyle(fontSize: 14)),
        ],
      ),
      onTap: () {
        onItemSelected(itemName, itemPrice); // Pass both itemName and itemPrice

        // onItemSelected('$itemName - ${double.parse(itemPrice).toStringAsFixed(2)}');
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}
