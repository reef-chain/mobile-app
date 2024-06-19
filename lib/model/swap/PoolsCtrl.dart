import 'package:reef_mobile_app/model/swap/pools_model.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class PoolsCtrl{
  final JsApiService jsApi;
  final PoolsModel poolsModel;

  PoolsCtrl( this.jsApi, this.poolsModel){
    fetchPools().then((pools) {
      poolsModel.setPools(pools);
      });
    jsApi.jsObservable('window.reefState.selectedNetwork\$')
        .listen((network)async{refetch(await fetchPools());});
  }

  Future<List<dynamic>>fetchPools()async{
    return await jsApi.jsPromise('window.utils.getPools(10,0,"","")');
  }

  List<dynamic> getCachedPools(){
    return poolsModel.pools;
  }

  void appendPools(List<dynamic> pools){
    final oldPool = poolsModel.pools;
    oldPool.addAll(pools);
    poolsModel.setPools(oldPool);
  }

  // fetches new pools on nw change
  void refetch(List<dynamic> pools){
    poolsModel.setPools(pools);
  }

  Future<dynamic> getPools(dynamic offset,String search) async {
    return jsApi.jsPromise('window.utils.getPools(10,${offset},"${search}","")');
  }
}