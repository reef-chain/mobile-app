import 'package:mobx/mobx.dart';

part 'pools_model.g.dart';

class PoolsModel = _PoolsModel with _$PoolsModel;

abstract class _PoolsModel with Store {
  @observable
  List<dynamic> pools = [];

  @action
  void setPools(List<dynamic> _pools) {
    pools = _pools;
  }

}
