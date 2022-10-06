import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/notification_provider.dart';
import 'package:lyotrade/screens/notification/widget.dart/painter.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';

class NotificationDetail extends StatefulWidget {
  NotificationDetail(this.item, this.getnotification);
  final item;
  final getnotification;

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  void initState() {
    // TODO: implement initState
    readNotification();
    super.initState();
  }

  Future<void> readNotification() async {
    var notificationProvider =
        Provider.of<Notificationprovider>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    await notificationProvider.readNotification(
        context, auth, widget.item['id']);
    await widget.getnotification();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.50,
      padding: EdgeInsets.all(15),
      color: bottombuttoncolour,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  DateFormat('dd-MM-y H:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse('${widget.item['ctime']}'))),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
              )
            ],
          ),
          SizedBox(
            height: height * 0.03,
          ),
          Flexible(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: seconadarytextcolour,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    widget.item['messageContent'].toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              CustomPaint(painter: Triangle(seconadarytextcolour)),
            ],
          )),
        ],
      ),
    );
  }
}
