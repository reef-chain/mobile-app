import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(pool['iconUrl1'], width: 24, height: 24),
                        SizedBox(width: 8),
                        Image.network(pool['iconUrl2'], width: 24, height: 24),
                      ],
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
}
