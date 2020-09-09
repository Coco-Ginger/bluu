import 'package:flutter/material.dart';
import 'package:chatapp/utils/universal_variables.dart';

import '../../../group_search_screen.dart';

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => GroupSearchScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
            color: UniversalVariables.fabColor,
            borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.add_comment,
          color: Colors.white,
          size: 25,
        ),
        padding: EdgeInsets.all(15),
      ),
    );
  }
}
