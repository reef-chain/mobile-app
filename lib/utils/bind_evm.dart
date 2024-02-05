import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';

const MIN_BALANCE = 5;

bool hasBalanceForFunding(ReefAccount reefSigner) {
  return reefSigner.balance >= BigInt.from(MIN_BALANCE * 1e18 * 2);
}

bool hasBalanceForBinding(ReefAccount reefSigner) {
  return reefSigner.balance >= BigInt.from(MIN_BALANCE * 1e18);
}

List<ReefAccount> getSignersWithEnoughBalance(ReefAccount bindFor) {
  List<ReefAccount> _availableTxAccounts = ReefAppState
      .instance.model.accounts.accountsList
      .where((signer) =>
          signer.address != bindFor.address && hasBalanceForFunding(signer))
      .toList();
  _availableTxAccounts.sort((a, b) => b.balance.compareTo(a.balance));
  return _availableTxAccounts;
}

bool hasThresholdBalance() {
  List<ReefAccount> accountsWithoutThreshold = ReefAppState
      .instance.model.accounts.accountsList
      .where((signer) => !signer.isEvmClaimed
          ? signer.balance < BigInt.from(MIN_BALANCE * 1e18)
          : false)
      .toList();

  if (accountsWithoutThreshold.isEmpty) return true;
  List<ReefAccount> fundingAccounts =
      getSignersWithEnoughBalance(accountsWithoutThreshold[0]);
  return fundingAccounts.isNotEmpty;
}
