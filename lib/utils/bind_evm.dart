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

bool anyAccountHasBalance(BigInt minBalance) {
  List<ReefAccount> accountsWithoutThreshold = ReefAppState
      .instance.model.accounts.accountsList
      .where((signer) => signer.balance < minBalance)
      .toList();

  if (accountsWithoutThreshold.isEmpty) return true;
  List<ReefAccount> fundingAccounts =
      getSignersWithEnoughBalance(accountsWithoutThreshold[0]);
  return fundingAccounts.isNotEmpty;
}
