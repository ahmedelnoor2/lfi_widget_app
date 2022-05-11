import 'package:flutter/material.dart';
import 'package:lyotrade/utils/AppConstant.utils.dart';
import 'package:lyotrade/utils/Colors.utils.dart';

import 'package:lyotrade/providers/public.dart';
import 'package:provider/provider.dart';

sideBar(context, auth) {
  width = MediaQuery.of(context).size.width;
  height = MediaQuery.of(context).size.height;

  var public = Provider.of<Public>(context, listen: true);

  return SizedBox(
    width: width,
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: height * 0.21,
            child: DrawerHeader(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  auth.userInfo.isEmpty
                      ? ListTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/authentication');
                          },
                          leading: const CircleAvatar(
                            child: Icon(Icons.account_circle),
                          ),
                          title: const Text(
                            'Login',
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: const Text('Welcome to LYOCOIN'),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        )
                      : ListTile(
                          leading: const CircleAvatar(
                            child: Text('AT'),
                          ),
                          title: Text(
                            '${auth.userInfo['userAccount']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Text('UID: ${auth.userInfo['id']}'),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ),
                ],
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Referral Program'),
              subtitle: Text(
                'Refer friends and get rewards',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Icons.star_border_outlined,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.list_alt),
                  title: Text('History'),
                ),
                ListTile(
                  leading: const Icon(Icons.percent),
                  title: const Text('Trading Fee Level'),
                  trailing: Text(
                    'Current Level: ${auth.userInfo['accountStatus']}',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.percent),
                  title: const Text('Pay Fees with LYO'),
                  subtitle: Text(
                    '20% off on trading fees',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                      value: false,
                      onChanged: (val) {
                        print(val);
                      }),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Security'),
                  trailing: Text(
                    'Payment and Password',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Currency'),
                  trailing: DropdownButton<String>(
                    icon: Container(),
                    isDense: true,
                    underline: Container(),
                    value: public.activeCurrency['fiat_symbol'],
                    // icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (newCurrency) async {
                      await public.changeCurrency(newCurrency);
                      await public.assetsRate();
                    },
                    items: public.currencies
                        .map<DropdownMenuItem<String>>((currency) {
                      return DropdownMenuItem<String>(
                        value: currency['fiat_symbol'],
                        child: Text(
                          '${currency['fiat_icon']} ${currency['fiat_symbol'].toUpperCase()}',
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ],
            ),
          ),
          auth.userInfo.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    auth.logout(context);
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Container()
        ],
      ),
    ),
  );
}
