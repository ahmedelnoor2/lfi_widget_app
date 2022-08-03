// import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:lyotrade/utils/Colors.utils.dart';

// class NotificationListingpage extends StatefulWidget {
//   const NotificationListingpage({Key? key}) : super(key: key);

//   @override
//   State<NotificationListingpage> createState() =>
//       _NotificationListingpageState();
// }

// class _NotificationListingpageState extends State<NotificationListingpage> {
//   String dropdownValue = 'All';

//   bool _isselected = false;

//   final titles = [
//     'aneep loytrade offers',
//     'loytrade offers',
//     'coins updating',
//     'notication is comming',
//     'aneep loytrade offers',
//     'loytrade offers',
//     'coins updating',
//     'notication is comming',
//     'aneep loytrade offers',
//     'loytrade offers',
//     'coins updating',
//     'notication is comming',
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: <Widget>[
//                   Checkbox(
//                       value: _isselected,
//                       onChanged: (value) {
//                         setState(() {
//                           _isselected = value ?? false;
//                         });
//                       }),
//                   Text("Select All"),
//                 ],
//               ),

              
//               Row(
                
//                 children: [
//                   Container(
//                     height: 35,
//                     child: ElevatedButton(
//                       child: Text(
//                         "Mark read",
//                         style: TextStyle(
//                           color: whiteTextColor,
//                         ),
//                       ),
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                           primary: bluechartColor,
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                           textStyle: TextStyle(
//                               fontSize: 16, fontWeight:FontWeight.w400)),
//                     ),
//                   ),
//                   SizedBox(width: 5,),
//                   Container(
//                     height: 35,
//                     child: ElevatedButton(
//                       child: Text(
//                         "Delete",
//                         style: TextStyle(
//                           color: whiteTextColor,
//                         ),
//                       ),
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                           primary: bluechartColor,
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                           textStyle: TextStyle(
//                               fontSize: 16, fontWeight:FontWeight.w400)),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: 12,
//             itemBuilder: (context, index) {
//               return Card(
//                 color: _isselected ? natuaraldark : null,
//                 //                           <-- Card widget
//                 child: ListTile(
//                   leading: Icon(Icons.message),
//                   title: Text(titles[index]),
//                   trailing: Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text('05-07-2022'),
//                         Icon(
//                           Icons.delete,
//                           color: Colors.red,
//                           size: 18,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }