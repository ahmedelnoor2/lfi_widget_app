import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/referral.dart';
import 'package:lyotrade/screens/common/no_data.dart';
import 'package:lyotrade/utils/Colors.utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Myinvitation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyinvitationState();
}

class _MyinvitationState extends State<Myinvitation> {
  
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refresherKey = GlobalKey();
  var pagesized=10;
  @override
  void initState() {
    getMyinvitation();
    super.initState();
  }

  Future<void> getMyinvitation() async {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: false);

    await referalprovider.getmyInvitation(context, auth,{"page": "1", "pageSize": "$pagesized"});
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    var referalprovider = Provider.of<ReferralProvider>(context, listen: true);


    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30, left: 16, right: 15, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friend\'s user ID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: referalprovider.isinvitation
              ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.3,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : referalprovider.invitationlist.isEmpty
                  ? Center(child: noData('No Invitation'))
                  : SmartRefresher(
                        key: _refresherKey,
                        controller: _refreshController,
                        enablePullDown: false,
                        enablePullUp: true,
                        physics: const BouncingScrollPhysics(),
                        footer: ClassicFooter(
                          loadStyle: LoadStyle.ShowWhenLoading,
                          completeDuration: Duration(milliseconds: 500),
                        ),
                        onLoading: (() async {
                          setState(() {
                          pagesized += 10;
                          });
                          return Future.delayed(
                            Duration(seconds: 2),
                            () async {
                              await referalprovider.getmyInvitation(context, auth,{"page": "1", "pageSize": "$pagesized"});

                              if (mounted) setState(() {});
                              _refreshController.loadFailed();
                            },
                          );
                        }),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: referalprovider.invitationlist.length,
                        itemBuilder: (context, index) {
                          var emailText = referalprovider.invitationlist[index]
                                  ['email']
                              .toString();
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            referalprovider.invitationlist[index]
                                                    ['levelZeroRegisterUid']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text(
                                              emailText.length > 30
                                                  ? '${emailText.substring(0, 15)}.....${emailText.substring(emailText.length - 10, emailText.length)}'
                                                  : emailText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            // width: 150,
                                            child: Text(
                                              DateFormat('yyy-mm-dd hh:mm:ss')
                                                  .format(DateTime
                                                      .fromMicrosecondsSinceEpoch(
                                                          referalprovider
                                                                      .invitationlist[
                                                                  index]
                                                              ['registerTime'])),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: seconadarytextcolour,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ),
        ),
      ],
    );
  }
}
