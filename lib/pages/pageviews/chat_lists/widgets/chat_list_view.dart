import 'package:bluu/pages/chatscreens/chat_screen.dart';
import 'package:bluu/pages/chatscreens/widgets/cached_image.dart';
import 'package:bluu/services/firestore_service.dart';
import 'package:bluu/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluu/models/contact.dart';
import 'package:bluu/models/user.dart';
import 'package:bluu/provider/user_provider.dart';
import 'package:bluu/resources/chat_methods.dart';
import 'package:bluu/widgets/custom_tile.dart';
import 'package:swipe_to/swipe_to.dart';

import 'last_message_container.dart';
import 'online_dot_indicator.dart';

class ChatListView extends StatelessWidget {
  final Contact contact;
  final FirestoreService _firestoreService = locator<FirestoreService>();
  ChatListView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _firestoreService.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        return SizedBox();
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return SwipeTo(
      swipeDirection: SwipeDirection.swipeToLeft,
      callBack: () {
        //TODO: IMPLEMENT CALL METHOD
        print("call method in this call back");
        //could implement optional choices
        // from settings a user chooses what swipe left does, call or archive
      },
      child: CustomTile(
          mini: false,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiver: contact,
                ),
              )),
          title: Padding(
            padding: EdgeInsets.only(left: 8, top: 0, right: 0, bottom: 0),
            child: Text(
              (contact != null ? contact.name : null) != null
                  ? contact.name
                  : "..",
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(left: 8, top: 0, right: 0, bottom: 0),
            child: LastMessageContainer(
              stream: _chatMethods.fetchLastMessageBetween(
                senderId: userProvider.getUser.uid,
                receiverId: contact.uid,
              ),
            ),
          ),
          leading: Container(
            constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
            child: Stack(
              children: <Widget>[
                CachedImage(
                  contact.profilePhoto,
                  radius: 80,
                  isRound: true,
                ),
                OnlineDotIndicator(
                  uid: contact.uid,
                ),
              ],
            ),
          ),
          trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 10),
                LastMessageTimeContainer(
                  stream: _chatMethods.fetchLastMessageBetween(
                    senderId: userProvider.getUser.uid,
                    receiverId: contact.uid,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 11,
                    minHeight: 11,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 1, left: 5, right: 5),
                    child: Text(
                      "2",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ])),
    );
  }
}
