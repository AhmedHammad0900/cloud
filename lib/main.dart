import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';


late Teams teams ;
late Users users ;
List<String> theFinalRoles = [] ;

Future<dynamic> main(final context) async {
  final client = Client()
     .setEndpoint('https://cloud.appwrite.io/v1')
     .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'])
     .setKey(Platform.environment['APPWRITE_API_KEY']);
  teams = Teams(client);
  users = Users(client);
  ParseData parsing = ParseData.fromJson(json.decode(context.req.body));
  // The `req` object contains the request data
  if (context.req.method == 'POST') {
    for ( int i = 0 ; i < parsing.roles.length ; i ++ ) {
      theFinalRoles.add(parsing.roles[i]) ;
    }
    try {
      Membership result = await teams.createMembership(
          teamId: parsing.teamId,
          roles: theFinalRoles,
          email: parsing.userEmail,
          url: "https://cloud.appwrite.io",
          name: "Dr.Dentist"
      );
      context.log(result.userEmail);
    }  on AppwriteException catch (e) {
      if (e.code == 409 ) {
        updateUser( parsing.teamId, parsing.userEmail.substring(0, parsing.userEmail.indexOf("@")) );
        context.log( "Updated ${parsing.userEmail}" );
      }

    }

    return context.res.send('Hello, World!');
  }




}


class ParseData {
  final String teamId;
  final String userEmail;
  final List<dynamic> roles;
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

Future<bool> updateUser(String theTeamId, String userEmail) async{
  UserList theUser =  await users.list(search: userEmail);
  MembershipList membershipList = await teams.listMemberships(teamId: theTeamId, search: theUser.users[0].$id) ;
  Membership membership = await teams.updateMembershipRoles(teamId: theTeamId, membershipId: membershipList.memberships[0].$id, roles: theFinalRoles) ;
  return membership.confirm ;
}