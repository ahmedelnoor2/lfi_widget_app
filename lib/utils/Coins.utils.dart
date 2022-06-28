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
