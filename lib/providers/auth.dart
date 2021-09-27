import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String webAPIKey = "AIzaSyBbXHzkR_vEzIxfD-Ilcefbq0rMoTI53RI";

    String _authUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$webAPIKey";

    final url = Uri.parse(_authUrl);
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['error'] != null) {
        print(responseData['error']['message']);
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }
}




// import 'dart:convert';

// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
// import 'package:shop_app/models/http_exception.dart';

// class Auth with ChangeNotifier {
//   String _token;
//   DateTime _expiryDate;
//   String _userId;

//   Future<void> _authenticate(
//       String email, String password, String urlSegment) async {
//     String webAPIKey = "AIzaSyBbXHzkR_vEzIxfD-Ilcefbq0rMoTI53RI";

//     String _authUrl =
//         "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$webAPIKey";

//     try {
//       final url = Uri.parse(_authUrl);

//       final response = await http.post(
//         url,
//         body: json.encode(
//           {
//             'email': email,
//             'password': password,
//             'returnSecureToken': true,
//           },
//         ),
//       );
//       final responseData = json.decode(response.body);
//       print(responseData);
//       if (responseData['error'] != null) {
//         throw HttpException(responseData['error']['meesage']);
//       }
//       // print(responseData);
//     } catch (error) {
//       print(error);
//       throw error;
//     }
//   }

//   Future<void> signup(String email, String password) async {
//     String urlSegment = "signUp";

//     return _authenticate(email, password, urlSegment);
//   }

//   Future<void> login(String email, String password) async {
//     String urlSegment = "signInWithPassword";
//     return _authenticate(email, password, urlSegment);
//   }
// }
