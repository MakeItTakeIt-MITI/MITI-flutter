import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'package:miti/common/component/default_appbar.dart';

class AddressScreen extends StatelessWidget {
  static String get routeName => 'address';

  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TextButton(
    //   onPressed: () async {
    //     await Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => KpostalView(
    //           // kakaoKey: '{Add your KAKAO DEVELOPERS JS KEY}',
    //           callback: (Kpostal result) {
    //             log('result  =${result}');
    //
    //           },
    //         ),
    //       ),
    //     );
    //   },
    //   style: ButtonStyle(
    //       backgroundColor:
    //       MaterialStateProperty.all<Color>(Colors.blue)),
    //   child: Text(
    //     'Search Address',
    //     style: TextStyle(color: Colors.white),
    //   ),
    // )

    return KpostalView(
      kakaoKey: '70c742501212b21cb4303ea86cccd074',
      callback: (Kpostal result){
        log('result  =${result}');
      },
    );
  }
}
