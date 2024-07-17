import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

// This is your Appwrite function
// It's executed each time we get a request
Future<dynamic> main(final context) async {
  final client = Client()
     .setEndpoint('https://cloud.appwrite.io/v1')
     .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'])
     .setKey(Platform.environment['APPWRITE_API_KEY']);
  Teams teams = Teams(client);
  ParseData parsing = await ParseData.fromJson(json.decode(context.req.body));
  // context.log('Hello, sss!');


  // The `req` object contains the request data
  if (context.req.method == 'POST') {
    try {
      Membership result = await teams.createMembership(
          teamId: parsing.teamId,
          roles: parsing.roles,
          email: parsing.userEmail,
          url: ""
      );
      context.log(result.userEmail);
    }  catch (e) {
      print("paresed but I am here") ;
    }

    return context.res.send('Hello, World!');
  }

    return context.res.json({
    'motto': 'Build like a team of hundreds_',
    'learn': 'https://appwrite.io/docs',
    'connect': 'https://appwrite.io/discord',
    'getInspired': 'https://builtwith.appwrite.io',
  });
}

class ParseData {
  final String teamId;
  final String userEmail;
  final List<String> roles;
  final String? adminDocumentId;
  final String? newUserOrPlus;

  const ParseData({required this.teamId,
    required this.userEmail,
    required this.roles,
    this.adminDocumentId,
    this.newUserOrPlus});

  factory ParseData.fromJson(Map<String, dynamic> json) {
    return ParseData(
        teamId: json['teamId'],
        userEmail: json['userEmail'],
        roles: json['roles'],
        adminDocumentId: json['myId'],
        newUserOrPlus: json['newUserOrPlus']);
  }
}