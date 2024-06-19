// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pools_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PoolsModel on _PoolsModel, Store {
  late final _$poolsAtom = Atom(name: '_PoolsModel.pools', context: context);

  @override
  List<dynamic> get pools {
    _$poolsAtom.reportRead();
    return super.pools;
  }

  @override
  set pools(List<dynamic> value) {
    _$poolsAtom.reportWrite(value, super.pools, () {
      super.pools = value;
    });
  }

  late final _$_PoolsModelActionController =
      ActionController(name: '_PoolsModel', context: context);

  @override
  void setPools(List<dynamic> _pools) {
    final _$actionInfo =
        _$_PoolsModelActionController.startAction(name: '_PoolsModel.setPools');
    try {
      return super.setPools(_pools);
    } finally {
      _$_PoolsModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pools: ${pools}
    ''';
  }
}
