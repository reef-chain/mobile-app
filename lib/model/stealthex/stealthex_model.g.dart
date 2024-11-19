// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stealthex_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StealthexModel on _StealthexModel, Store {
  late final _$currenciesAtom =
      Atom(name: '_StealthexModel.currencies', context: context);

  @override
  List<dynamic> get currencies {
    _$currenciesAtom.reportRead();
    return super.currencies;
  }

  @override
  set currencies(List<dynamic> value) {
    _$currenciesAtom.reportWrite(value, super.currencies, () {
      super.currencies = value;
    });
  }

  late final _$_StealthexModelActionController =
      ActionController(name: '_StealthexModel', context: context);

  @override
  void setCurrencies(List<dynamic> _currencies) {
    final _$actionInfo = _$_StealthexModelActionController.startAction(
        name: '_StealthexModel.setCurrencies');
    try {
      return super.setCurrencies(_currencies);
    } finally {
      _$_StealthexModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currencies: ${currencies}
    ''';
  }
}
