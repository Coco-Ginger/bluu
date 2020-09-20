
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluu/provider/user_provider.dart';
import 'package:bluu/utils/universal_variables.dart';
import 'package:bluu/utils/utilities.dart';

class UserCircle extends StatelessWidget {
  final GestureTapCallback onTap;

  UserCircle({
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
        onTap: () {
          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (BuildContext context) => UserProfile()));
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: UniversalVariables.appBarUserIcon,
          ),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  Utils.getInitials(userProvider.getUser.name),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: UniversalVariables.whiteColor,
                    fontSize: 13,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: UniversalVariables.appBarUserIcon, width: 1),
                      color: UniversalVariables.onlineDotColor),
                ),
              )
            ],
          ),
        ));
  }
}
