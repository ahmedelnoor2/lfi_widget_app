String getCoinType(String coinType) {
  switch (coinType) {
    case 'ERC20':
      return 'EUSDT';
    case 'Omni':
      return 'USDT';
    case 'TRC20':
      return 'TUSDT';
    case 'BSC':
      return 'USDTBSC';
    default:
      return 'EUSDT';
  }
}

String getCoinName(String coinName) {
  switch (coinName) {
    case 'LYO1':
      return 'LYO';
    case 'BUSD2':
      return 'BUSD';
    default:
      return coinName;
  }
}

String getMarketName(String coinName) {
  switch (coinName) {
    case 'LYO1/USDT':
      return 'LYO/USDT';
    default:
      return coinName;
  }
}

String findCommonCoinType(firstCoin, secondCoin) {
  var str = firstCoin;
  var str2 = secondCoin;

  Set<String> uniqueList = {};
  for (int i = 0; i < str.length; i++) {
    if (str2.contains(str[i])) {
      uniqueList.add(str[i]);
    }
  }
  return uniqueList.join();
}
