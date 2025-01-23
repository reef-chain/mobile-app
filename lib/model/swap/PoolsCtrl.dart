import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/swap/pools_model.dart';

class PoolsCtrl{
  final PoolsModel poolsModel;
  final ReefChainApi reefChainApi;

  PoolsCtrl(  this.poolsModel,this.reefChainApi){
    fetchPools().then((pools) {
      poolsModel.setPools(pools);
      });
    reefChainApi.reefState.networkApi.selectedNetwork$
        .listen((network)async{refetch(await fetchPools());});
  }

  Future<List<dynamic>>fetchPools()async{
    return await reefChainApi.reefState.poolsApi.fetchPools();
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
    return await reefChainApi.reefState.poolsApi.getPools(offset,search);
  }
}