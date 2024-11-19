import 'package:mobx/mobx.dart';

part 'stealthex_model.g.dart';

class StealthexModel = _StealthexModel with _$StealthexModel;

abstract class _StealthexModel with Store {
  @observable
  List<dynamic> currencies = [];

  @action
  void setCurrencies(List<dynamic> _currencies) {
    currencies = _currencies;
  }

}
