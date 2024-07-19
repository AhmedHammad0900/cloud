import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:starter_template/TextManager.dart';


late Teams teams ;
late Users users ;
late Databases databases ;
int balance = 0 ;
int price = 0 ;
List<String> theFinalRoles = [] ;

Future<dynamic> main(final context) async {
  final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'])
      .setKey(Platform.environment['APPWRITE_API_KEY']);
  teams = Teams(client);
  users = Users(client);
  databases = Databases(client);
  ParseData parsing = ParseData.fromJson(json.decode(context.req.body));
  // The `req` object contains the request data
  if (context.req.method == 'POST') {
    theFinalRoles = [] ;
    for ( int i = 0 ; i < parsing.roles.length ; i ++ ) {
      theFinalRoles.add(parsing.roles[i]) ;
    }
    Document adminDocument = await databases.getDocument(databaseId: TextManager.managementDatabase, collectionId: TextManager.managerCollections, documentId: parsing.adminDocumentId) ;
    balance = adminDocument.data['money'] ;
    price = adminDocument.data['price'] ;
    try {
      if (balance >= price ) {
        Document adminDocument = await databases.updateDocument(databaseId: TextManager.managementDatabase, collectionId: TextManager.managerCollections, documentId: parsing.adminDocumentId!, data: {"money" : balance-price}) ;
        Membership result = await teams.createMembership(
          teamId: parsing.teamId,
          roles: theFinalRoles,
          email: parsing.userEmail,
          url: TextManager.url,
          name: TextManager.nameUser
      );

       context.log("Added $theFinalRoles to ${result.userEmail}");
        return context.res.json({
          'motto': 'Build like a team of hundreds_',
          'learn': 'https://appwrite.io/docs',
          'connect': 'https://appwrite.io/discord',
          'getInspired': 'https://builtwith.appwrite.io',
        });

      }

    }  on AppwriteException catch (e) {
      if (e.code == 409 ) {
        await UpdateUserClass.updateUser( parsing.teamId, parsing.userEmail.substring(0, parsing.userEmail.indexOf("@")) );
        context.log(UpdateUserClass.theMessage);
      }
    }
    context.res.send("hello world");
    return context.res.json({
      'motto': 'Build like a team of hundreds_',
      'learn': 'https://appwrite.io/docs',
      'connect': 'https://appwrite.io/discord',
      'getInspired': 'https://builtwith.appwrite.io',
    });
  }
}


class ParseData {
  final String teamId;
  final String userEmail;
  final List<dynamic> roles;
  final String adminDocumentId;
  final String? newUserOrPlus;

  const ParseData({required this.teamId,
    required this.userEmail,
    required this.roles,
    required this.adminDocumentId,
    this.newUserOrPlus});

  factory ParseData.fromJson(Map<String, dynamic> json) {
    return ParseData(
        teamId: json['teamId'],
        userEmail: json['userEmail'],
        roles: json['roles'],
        adminDocumentId: json['adminId'],
        newUserOrPlus: json['newUserOrPlus']);
  }
}



class UpdateUserClass {
 static String theMessage = "" ;


static Future<bool> updateUser(String theTeamId, String userEmail ) async {
  List<String> theOldAccess = [];
  List<String> theFinalList = [];
  UserList theUser = await users.list(search: userEmail);
  MembershipList membershipList = await teams.listMemberships(teamId: theTeamId, search: theUser.users[0].$id);
  if (membershipList.memberships[0].roles.toString().contains("FirstTerm")) {
    theOldAccess.add("FirstTerm");
  }
  if (membershipList.memberships[0].roles.contains("SecondTerm")) {
    theOldAccess.add("SecondTerm");
  }
  if ( theOldAccess.contains("FirstTerm") && theOldAccess.contains("SecondTerm")) {
    theMessage = "User : '$userEmail' \nAlready Have Both Terms" ;
    return true;
  }
  if ( listEquals( theOldAccess, theFinalRoles) == true) {
    theMessage = "User : $userEmail \nAlready Have the Same Access" ;
    return true;
  } else {
    theFinalList = theOldAccess + theFinalRoles;
    Membership membership = await teams.updateMembershipRoles(teamId: theTeamId,membershipId: membershipList.memberships[0].$id, roles: theFinalList);
    theMessage = "Updated '${membershipList.memberships[0].userEmail}' To :$theFinalRoles" ;
    return membership.confirm;
    }
   }
 }

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}