import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

import 'Home_Screen.dart';
import 'Signup_Screen.dart';

class LoginScreen extends StatefulWidget {

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;


  // Inside your LoginScreen class
  void _navigateBackToProductDetailsPage(BuildContext context) {
    // Replace these placeholder values with the actual user's mobile number and product
    String userMobileNumber = _mobileController.text;
    // Product userProduct = Product(/* Initialize your product */);

    Navigator.pop(context, userMobileNumber);
    // Navigator.pop(context, userProduct);
  }


  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'https://apip.trifrnd.com/fruits/inv.php?apicall=login';

    await Future.delayed(const Duration(seconds: 1));

    final response = await http.post(Uri.parse(apiUrl),
        body: {
          "mobile": _mobileController.text,
          "password": _passwordController.text,
        });

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData == "OK") {
        final user = json.decode(response.body)[0];
        try {
          // final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

          // Save the mobile number and login status
          // sharedPreferences.setString('mobile', _mobileController.text);
          // sharedPreferences.setBool('isLoggedIn', true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                // mobileNumber: _mobileController.text,
              ),
            ),
          );
        } catch (e) {
          print('Error: $e');
        }
      } else {
        Fluttertoast.showToast(
          msg: "Invalid mobile number or password!",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Server Connection Error!",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Sign In"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Set this to false to hide the back button

        // backgroundColor: Colors.orange,
      ),
      body:
      Center(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text( "Sign In",
                  style: TextStyle(color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 30,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile',
                      hintText: 'Enter Mobile Number',
                      prefixIcon: Icon(Icons.mobile_friendly),
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 10,  // Set the maximum length
                    // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (String value) {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a mobile';
                      } else if (value.length < 10) {
                        return 'Mobile number must be 10 Digits';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      prefixIcon: const Icon(Icons.password),
                      border: const OutlineInputBorder(),
                      // Password visibility toggle
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    onChanged: (String value) {},
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please Enter Password'
                          : null;
                    },
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     const SizedBox(width: 220,),
                //     GestureDetector(
                //       onTap: () {
                //         // Navigator.push(context,
                //         //     MaterialPageRoute(builder: (context) =>
                //         //         ForgotPassMobileVerify()));
                //       },
                //       child: const Text(
                //         'Forgot Password?',
                //         style: TextStyle(
                //           color: Colors.orange,
                //           fontSize: 14,
                //           decoration: TextDecoration.underline, // Add underline decoration here
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 30,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () async {
                      // Handle login logic here
                      if (_formKey.currentState!.validate()) {
                        // Show loading indicator
                        setState(() {
                          _isLoading = true;
                        });

                        // Perform the login
                        await _login();

                        // Hide loading indicator after login completes
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    ) // Show loading indicator when _isLoading is true
                        : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                // Don't have an account? Sign Up.
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                        // SignUpScreen()
                        SignUpScreen(
                          // product: widget.product,
                        )
                        ));
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),

      ),

    );
  }
}
