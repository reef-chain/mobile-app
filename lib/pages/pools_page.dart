import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';

class PoolsPage extends StatefulWidget {
  const PoolsPage({super.key});

  @override
  State<PoolsPage> createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> {
  Future<List<dynamic>>? _pools;

  @override
  void initState() {
    super.initState();
    _fetchPools();
  }

  void _fetchPools() async {
    final pools = await ReefAppState.instance.tokensCtrl.getPools();
    if (pools is List<dynamic>) {
      setState(() {
        _pools = Future.value(pools);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _pools,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var pool = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 44,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        ClipOval(
  child: isValidSVG(pool['iconUrl1'])
      ? SvgPicture.string(
          utf8.decode(base64.decode(
            pool['iconUrl1'].split('data:image/svg+xml;base64,')[1],
          )),width: 24, height: 24
        )
      : Image.network(pool['iconUrl1'], width: 24, height: 24, fit: BoxFit.cover),
),

                        Positioned(
                          left: 14,
                          child: ClipOval(
                            child:  isValidSVG(pool['iconUrl2'])
      ? SvgPicture.string(
          utf8.decode(base64.decode(
            pool['iconUrl2'].split('data:image/svg+xml;base64,')[1],
          )),width: 24, height: 24
        )
      : Image.network(pool['iconUrl2'], width: 24, height: 24, fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text('${pool['name1']} - ${pool['name2']}'),
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  bool isValidSVG(String? dataUrl) {
    return dataUrl != null && dataUrl.contains("data:image/svg+xml;base64,");
  }
}
