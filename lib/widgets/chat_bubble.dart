import 'dart:math';
import 'package:bluu/pages/chatscreens/widgets/cached_image.dart';
import 'package:bluu/pages/weview.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:simple_url_preview/simple_url_preview.dart';

class ChatBubble extends StatefulWidget {
  final String message, time, username, type, urls, replyText, replyName;
  final bool isMe, isGroup, isReply;

  ChatBubble(
      {@required this.message,
      @required this.time,
      @required this.isMe,
      @required this.isGroup,
      @required this.urls,
      @required this.username,
      @required this.type,
      @required this.replyText,
      @required this.isReply,
      @required this.replyName});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  List colors = Colors.primaries;
  static Random random = Random();
  int rNum = random.nextInt(18);

  Color chatBubbleColor() {
    if (widget.isMe) {
      return Colors.grey[400];
    } else {
      return Colors.blue[300];
    }
  }

  Color chatBubbleReplyColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[200];
    } else {
      return Colors.grey[200];
    }
  }

  @override
  Widget build(BuildContext context) {
    final align =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = widget.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: chatBubbleColor(),
            borderRadius: radius,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.3,
            minWidth: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              widget.isMe
                  ? SizedBox()
                  : widget.isGroup
                      ? Padding(
                          padding: EdgeInsets.only(right: 48.0),
                          child: Container(
                            child: Text(
                              widget.username,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors[rNum],
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                        )
                      : SizedBox(),
              widget.isGroup
                  ? widget.isMe
                      ? SizedBox()
                      : SizedBox(height: 5)
                  : SizedBox(),
              widget.isReply
                  ? Container(
                      decoration: BoxDecoration(
                        color: chatBubbleReplyColor(),
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      constraints: BoxConstraints(
                        minHeight: 25,
                        maxHeight: 100,
                        minWidth: 80,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: Text(
                                widget.isMe ? "You" : widget.replyName,
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
                            //TODO: Image reply to render an image
                            widget.type == 'text'
                                ? Container(
                                    child: Text(
                                      widget.replyText,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
                                      maxLines: 2,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  )
                                : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedImage(widget.message,
                                    height: 250, width: 200, fit: BoxFit.cover),
                              )
                          ],
                        ),
                      ),
                    )
                  : SizedBox(width: 2),
              widget.isReply ? SizedBox(height: 5) : SizedBox(),
              Padding(
                  padding: EdgeInsets.all(widget.type == "text" ? 5 : 0),
                  child: widget.type == "text"
                      ? !widget.isReply
                          ? Text(widget.message ?? '',
                              style: TextStyle(
                                color: Colors.black,
                              ))
                          : Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.message ?? '',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal),
                              ),
                            )
                      : FullScreenWidget(
                          child: Hero(
                              tag: widget.message,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedImage(widget.message,
                                    height: 250, width: 200, fit: BoxFit.cover),
                              )))),
              SimpleUrlPreview(
                url: widget.urls.isNotEmpty ? widget.urls : '',
                textColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                onTap: () {
                  return Get.to(WeViewPage(url: widget.urls));
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: widget.isMe
              ? EdgeInsets.only(
                  right: 10,
                  bottom: 10.0,
                )
              : EdgeInsets.only(
                  left: 10,
                  bottom: 10.0,
                ),
          child: Text(
            widget.time,
            style: TextStyle(
              color: Theme.of(context).textTheme.title.color,
              fontSize: 10.0,
            ),
          ),
        ),
      ],
    );
  }
}
