String getTranslate(String text) {
  switch (text) {
    case '发送过于频繁，稍后再试':
      return 'Sending too often, try again later';
    case '当前币种不允许市价交易':
      return 'The current currency does not allow market trading';
    case '参数错误':
      return 'Parameter error';
    case '可用余额不足':
      return 'Insufficient available balance';
    default:
      return text;
  }
}
