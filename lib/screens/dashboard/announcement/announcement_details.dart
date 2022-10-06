import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/screens/common/header.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:provider/provider.dart';
import 'package:webviewx/webviewx.dart';

class AnnouncementDetails extends StatefulWidget {
  static const routeName = '/announcement_details';

  const AnnouncementDetails({
    Key? key,
    this.announcementDetails,
  }) : super(key: key);

  final announcementDetails;

  @override
  State<AnnouncementDetails> createState() => _AnnouncementDetailsState();
}

class _AnnouncementDetailsState extends State<AnnouncementDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  WebViewXController? _webController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    var public = Provider.of<Public>(context, listen: true);
    return Scaffold(
      appBar: appBar(context, null),
      body: WebViewX(
        key: const ValueKey('webviewx'),
        height: height,
        width: width,
        initialContent:
            '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><style>img{max-width: 100%;height: auto;}</style></head><body>${public.selectedAnnouncement['content']} </body> </html>',
        initialSourceType: SourceType.html,
        onWebViewCreated: (controller) async {
          // _controller = _webController;
          controller.loadContent(
              '<!DOCTYPE html> <html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><style>img{max-width: 100%;height: auto;}</style></head><body>${public.selectedAnnouncement['content']} </body> </html>',
              SourceType.html);
        },
        onPageStarted: (src) =>
            debugPrint('A new page has started loading: $src\n'),
        onPageFinished: (src) =>
            debugPrint('The page has finished loading: $src\n'),
      ),
    );
  }
}
