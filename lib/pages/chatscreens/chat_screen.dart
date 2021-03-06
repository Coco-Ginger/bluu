import 'dart:io';
import 'dart:convert';

import 'package:bluu/pages/callscreens/pickup/pickup_layout.dart';
import 'package:bluu/pages/chatscreens/widgets/cached_image.dart';
import 'package:bluu/services/authentication_service.dart';
import 'package:bluu/services/firestore_service.dart';
import 'package:bluu/utils/locator.dart';
import 'package:bluu/utils/url_extractor.dart';
import 'package:bluu/widgets/chat_bubble.dart';
import 'package:bluu/widgets/chatappbar.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:http/http.dart' as http;
import 'package:bluu/configs/firebase_configs.dart';
// import 'package:bluu/widgets/mainappbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bluu/constants/strings.dart';
import 'package:bluu/enum/view_state.dart';
import 'package:bluu/models/message.dart';
import 'package:bluu/models/user.dart';
import 'package:bluu/provider/image_upload_provider.dart';
import 'package:bluu/resources/storage_methods.dart';
import 'package:bluu/resources/chat_methods.dart';
import 'package:bluu/utils/call_utilities.dart';
import 'package:bluu/utils/permissions.dart';
import 'package:bluu/utils/universal_variables.dart';
import 'package:bluu/utils/utilities.dart';
import 'package:bluu/widgets/custom_tile.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState(this.receiver);
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final FirestoreService _firestoreService = locator<FirestoreService>();

  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  ScrollController _listScrollController = ScrollController();

  User sender;
  Message replyMessage;
  String _currentUserId;

  bool isWriting = false;

  bool showEmojiPicker = false;

  ImageUploadProvider _imageUploadProvider;

  User receiver;
  bool reply = false;
  _ChatScreenState(this.receiver);

  @override
  void initState() {
    super.initState();
    User user = _authenticationService.currentUser;
    _currentUserId = user.uid;

    setState(() {
      sender = User(
        uid: user.uid,
        name: user.name,
        profilePhoto: user.profilePhoto,
      );
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    // Size media = MediaQuery.of(context).size;

    return PickupLayout(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 3,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: InkWell(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0.0, right: 10.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "${widget.receiver.profilePhoto}",
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.receiver.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {},
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add_circle,
              ),
              onPressed: () {
                String _alertdialogTitle,
                    _alertdialogDescription,
                    _alertdialogOkButton;
                _alertdialogTitle = 'Add people to chat';
                _alertdialogDescription =
                    'This feature has not been implemented yet!';
                _alertdialogOkButton = 'Ok';
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        _alertdialogTitle,
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                              _alertdialogDescription,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            _alertdialogOkButton,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.video_call,
              ),
              onPressed: () async =>
                  await Permissions.cameraandmicrophonePermissionsGranted()
                      ? sendNotification(
                              "You have a video call from ${sender.name}",
                              sender.name,
                              widget.receiver.firebaseToken)
                          .then((value) => CallUtils.dialVideo(
                              from: sender,
                              to: widget.receiver,
                              context: context,
                              callis: "video"))
                      : {},
            ),
            IconButton(
              icon: Icon(
                Icons.phone,
              ),
              onPressed: () async {
                return await Permissions.microphonePermissionsGranted()
                    ? sendNotification("You have a call from ${sender.name}",
                            sender.name, widget.receiver.firebaseToken)
                        .then((value) => CallUtils.dialVoice(
                            from: sender,
                            to: widget.receiver,
                            context: context,
                            callis: "audio"))
                    : {};
              },
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Theme.of(context).brightness == Brightness.dark
                  ? FlareActor('assets/flare/cosmos.flr', animation: 'Untitled')
                  : FlareActor('assets/flare/penguin.flr',
                      animation: 'music_walk'),
            ),
            Column(
              children: <Widget>[
                Flexible(
                  child: messageList(),
                ),
                _imageUploadProvider.getViewState == ViewState.LOADING
                    ? Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 15),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                reply ? chatControlsReply(replyMessage) : chatControlsNormal(),
                showEmojiPicker
                    ? Container(child: emojiContainer())
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Theme.of(context).canvasColor,
      indicatorColor: Theme.of(context).accentColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            // mention the arrow syntax if you get the time
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget daySpan(context, message) {
    return Container(
        child: Center(
      child: Text("Yesterday"),
    ));
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);
    var time = _message.timestamp.toDate().toLocal();
    var newFormat = DateFormat("Hm");
    String timeT = newFormat.format(time);
    return SwipeTo(
      swipeDirection: SwipeDirection.swipeToLeft,
      endOffset: Offset(50.0, 0.0),
      callBack: () {
        setState(() {
          replyMessage = _message;
          reply = true;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Container(
            alignment: _message.senderId == _currentUserId
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: _message.type != MESSAGE_TYPE_IMAGE
                ? ChatBubble(
                    isGroup: false,
                    isMe: _message.senderId == _currentUserId,
                    message: _message.message,
                    replyText: _message.replyText,
                    time: timeT,
                    type: _message.type,
                    urls: _message.urls.length > 0 ? _message.urls[0] : '',
                    username: widget.receiver.name,
                    replyName: widget.receiver.name,
                    isReply: _message.isReply,
                  )
                : ChatBubble(
                    isGroup: false,
                    isMe: _message.senderId == _currentUserId ? true : false,
                    message: _message.photoUrl,
                    replyText: _message.replyText,
                    time: timeT,
                    urls: _message.urls.length > 0 ? _message.urls[0] : '',
                    type: _message.type,
                    username: widget.receiver.name,
                    replyName: widget.receiver.name,
                    isReply: _message.isReply,
                  )),
      ),
    );
  }

  Future<http.Response> sendNotification(
      String message, String sender, String receiver) {
    print("Firebase Token: " + receiver);
    return http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Authorization': 'key=$SERVER_KEY',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        // "message": {
        "to": "$receiver",
        "collapse_key": "type_a",
        "priority": "high",
        "notification": {
          "title": "$sender",
          "body": "$message",
        },
        "data": {
          "title": "$sender",
          "body": "$message",
          "sound": "default",
          "tag": "$sender",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
        // }
      }),
    );
  }

  Widget chatControlsNormal() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.tab,
                      ),
                      ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts,
                      ),
                      ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.add_location,
                      ),
                      ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a skype call and get reminders",
                        icon: Icons.schedule,
                      ),
                      ModalTile(
                        title: "Create Poll",
                        subtitle: "Share polls",
                        icon: Icons.poll,
                      )
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;
      var urls = urlLink(text);
      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        urls: urls,
        isReply: false,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _chatMethods.addMessageToDb(_message, sender, widget.receiver);
      sendNotification(_message.message.toString(), sender.name.toString(),
          widget.receiver.firebaseToken.toString());

      Firestore.instance
          .collection('users')
          .document(sender.uid)
          .collection('message_contacts')
          .document(widget.receiver.uid)
          .setData(
              {"contact_id": widget.receiver.uid, "added_on": Timestamp.now()},
              merge: true);
      Firestore.instance
          .collection('users')
          .document(widget.receiver.uid)
          .collection('message_contacts')
          .document(sender.uid)
          .setData({
        "contact_id": sender.uid,
        "username": sender.username,
        "name": sender.name,
        "status": sender.status,
        "added_on": Timestamp.now()
      }, merge: true);
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () => addMediaModal(context),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: textFieldController,
                      focusNode: textFieldFocus,
                      onTap: () => hideEmojiContainer(),
                      style: TextStyle(color: Colors.black),
                      onChanged: (val) {
                        (val.length > 0 && val.trim() != "")
                            ? setWritingTo(true)
                            : setWritingTo(false);
                      },
                      decoration: InputDecoration(
                          hintText: "Type a message",
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(50.0),
                              ),
                              borderSide: BorderSide.none),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    ),
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        if (!showEmojiPicker) {
                          // keyboard is visible
                          hideKeyboard();
                          showEmojiContainer();
                        } else {
                          //keyboard is hidden
                          showKeyboard();
                          hideEmojiContainer();
                        }
                      },
                      icon: Icon(
                        Icons.face,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              isWriting
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.record_voice_over,
                      ),
                    ),
              isWriting
                  ? Container()
                  : GestureDetector(
                      child: Icon(
                        Icons.camera_alt,
                      ),
                      onTap: () => pickImage(source: ImageSource.camera),
                    ),
              isWriting
                  ? Container(
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          size: 24,
                        ),
                        onPressed: () => sendMessage(),
                      ))
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  Widget chatControlsReply(Message message) {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.tab,
                      ),
                      ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts,
                      ),
                      ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.add_location,
                      ),
                      ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a skype call and get reminders",
                        icon: Icons.schedule,
                      ),
                      ModalTile(
                        title: "Create Poll",
                        subtitle: "Share polls",
                        icon: Icons.poll,
                      )
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;
      var urls = urlLink(text);
      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        urls: urls,
        isReply: true,
        replyText: message.type == 'text' ? message.message : message.photoUrl,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        reply = false;
        isWriting = false;
      });

      textFieldController.text = "";

      _chatMethods.addMessageToDb(_message, sender, widget.receiver);
      sendNotification(_message.message.toString(), sender.name.toString(),
          widget.receiver.firebaseToken.toString());

      Firestore.instance
          .collection('users')
          .document(sender.uid)
          .collection('message_contacts')
          .document(widget.receiver.uid)
          .setData(
              {"contact_id": widget.receiver.uid, "added_on": Timestamp.now()},
              merge: true);
      Firestore.instance
          .collection('users')
          .document(widget.receiver.uid)
          .collection('message_contacts')
          .document(sender.uid)
          .setData({
        "contact_id": sender.uid,
        "username": sender.username,
        "name": sender.name,
        "status": sender.status,
        "added_on": Timestamp.now()
      }, merge: true);
    }

    Color chatBubbleReplyColor() {
      if (Theme.of(context).brightness == Brightness.dark) {
        return Colors.grey[200];
      } else {
        return Colors.grey[200];
      }
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          reply
              ? GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      reply = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: chatBubbleReplyColor(),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    constraints: BoxConstraints(
                      minHeight: 25,
                      maxHeight: 300,
                      minWidth: 80,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Text(
                              message.senderId == _currentUserId
                                  ? "You"
                                  : widget.receiver.name,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.left,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          SizedBox(height: 2),
                          message.type == 'text'
                              ? Container(
                                  child: Text(
                                    message.message,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                  ),
                                  alignment: Alignment.centerLeft,
                                )
                              : Container(
                                  height: 200,
                                  child: Image.network(message.photoUrl,
                                      fit: BoxFit.cover)),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox(width: 2),
          SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () => addMediaModal(context),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      controller: textFieldController,
                      focusNode: textFieldFocus,
                      onTap: () => hideEmojiContainer(),
                      style: TextStyle(color: Colors.black),
                      onChanged: (val) {
                        (val.length > 0 && val.trim() != "")
                            ? setWritingTo(true)
                            : setWritingTo(false);
                      },
                      decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(50.0),
                              ),
                              borderSide: BorderSide.none),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    ),
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        if (!showEmojiPicker) {
                          // keyboard is visible
                          hideKeyboard();
                          showEmojiContainer();
                        } else {
                          //keyboard is hidden
                          showKeyboard();
                          hideEmojiContainer();
                        }
                      },
                      icon: Icon(
                        Icons.face,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              isWriting
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.record_voice_over,
                      ),
                    ),
              isWriting
                  ? Container()
                  : GestureDetector(
                      child: Icon(
                        Icons.camera_alt,
                      ),
                      onTap: () => pickImage(source: ImageSource.camera),
                    ),
              isWriting
                  ? Container(
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          size: 24,
                        ),
                        onPressed: () => sendMessage(),
                      ))
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        widget.receiver.name,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.add_circle,
          ),
          onPressed: () {
            String _alertdialogTitle,
                _alertdialogDescription,
                _alertdialogOkButton;
            _alertdialogTitle = 'Add people to chat';
            _alertdialogDescription =
                'This feature has not been implemented yet!';
            _alertdialogOkButton = 'Ok';
            showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: UniversalVariables.separatorColor,
                  title: Text(
                    _alertdialogTitle,
                    style: TextStyle(
                      color: UniversalVariables.blueColor,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                          _alertdialogDescription,
                          style: TextStyle(
                            color: UniversalVariables.blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        _alertdialogOkButton,
                        style: TextStyle(
                          color: UniversalVariables.blueColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.video_call,
          ),
          onPressed: () async =>
              await Permissions.cameraandmicrophonePermissionsGranted()
                  ? CallUtils.dialVideo(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                      callis: "video")
                  : {},
        ),
        IconButton(
          icon: Icon(
            Icons.phone,
          ),
          onPressed: () async =>
              await Permissions.microphonePermissionsGranted()
                  ? CallUtils.dialVoice(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                      callis: "audio")
                  : {},
        )
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
