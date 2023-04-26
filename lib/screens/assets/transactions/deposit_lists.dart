// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:lyotrade/providers/asset.dart';
// import 'package:lyotrade/utils/Coins.utils.dart';
// import 'package:lyotrade/utils/Colors.utils.dart';
// import 'package:provider/provider.dart';

// Widget depositList(context, width, height, allDeposits, public) {
//   return Column(
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//             width: width * 0.4,
//             child: Text(
//               'Currency',
//               style: TextStyle(
//                 color: secondaryTextColor,
//               ),
//             ),
//           ),
//           Text(
//             'Amount',
//             style: TextStyle(
//               color: secondaryTextColor,
//             ),
//           ),
//           Text(
//             'Status',
//             style: TextStyle(
//               color: secondaryTextColor,
//             ),
//           ),
//         ],
//       ),
//       Divider(
//         height: 0,
//       ),
//       Expanded(
//         flex: 2,
//         child: ListView.builder(
//           scrollDirection: Axis.vertical,
//           itemCount: allDeposits.length,
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemBuilder: (BuildContext context, int index) {
//             var deposit = allDeposits[index];
//             return InkWell(
//               onTap: () async {
//                 var asset = Provider.of<Asset>(context, listen: false);
//                 await asset.setTransactionDetails(deposit);
//                 Navigator.pushNamed(context, '/transaction_details');
//               },
//               child: Container(
//                 padding: EdgeInsets.only(top: 10, bottom: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.only(right: 10),
//                           child: CircleAvatar(
//                             radius: 15,
//                             child: public.publicInfoMarket['market']['coinList']
//                                         [deposit['symbol']] !=
//                                     null
//                                 ? Image.network(
//                                     '${public.publicInfoMarket['market']['coinList'][deposit['symbol']]['icon']}')
//                                 : Icon(
//                                     Icons.hourglass_empty,
//                                     color: Colors.white,
//                                   ),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                   '${getCoinName('${public.publicInfoMarket['market']['coinList'][deposit['symbol']]['showName']}')}'),
//                               Text(
//                                 '${DateFormat('dd-MM-y H:mm').format(DateTime.parse(deposit['createdAt']))}',
//                                 style: TextStyle(
//                                     color: secondaryTextColor, fontSize: 12),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                       child: Text(
//                         '${deposit['amount']}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       child: SizedBox(
//                         height: height * 0.035,
//                         width: width * 0.18,
//                         child: Card(
//                           shadowColor: Colors.transparent,
//                           color: greenPercentageIndicator,
//                           child: Center(
//                             child: Text(
//                               '${deposit['status_text']}',
//                               style: TextStyle(
//                                 color: greenIndicator,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }
