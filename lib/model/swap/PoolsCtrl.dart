import 'package:reef_mobile_app/model/swap/pools_model.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class PoolsCtrl{
  final JsApiService jsApi;
  final PoolsModel poolsModel;

  PoolsCtrl( this.jsApi, this.poolsModel){
    jsApi.jsPromise('window.utils.getPools(10,0,"","")').then((pools) {
      poolsModel.setPools(pools);
      });
  }

  List<dynamic> getCachedPools(){
    return poolsModel.pools;
  }

  void appendPools(List<dynamic> pools){
    final oldPool = poolsModel.pools;
    oldPool.addAll(pools);
    poolsModel.setPools(oldPool);
  }
}