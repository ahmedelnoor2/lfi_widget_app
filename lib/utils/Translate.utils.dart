String getTranslate(String text) {
  switch (text) {
    case '发送过于频繁，稍后再试':
      return 'Sending too often, try again later';
    case '当前币种不允许市价交易':
      return 'The current currency does not allow market trading';
    case '参数错误':
      return 'Parameter error';
    case '人机验证失败':
      return 'CAPTCHA failed';
    case '可用余额不足':
      return 'Insufficient available balance';
    case '谷歌校验码不正确':
      return 'Google check code is incorrect';
    case '用户不存在':
      return 'User does not exist';
    case '用户名或密码错误,您还有4次机会':
      return 'Incorrect username or password, you have 4 more chances';
    case '用户名或密码错误,您还有3次机会':
      return 'Incorrect username or password, you have 3 more chances';
    case '用户名或密码错误,您还有2次机会':
      return 'Incorrect username or password, you have 2 more chances';
    case '用户名或密码错误,您还有1次机会':
      return 'Incorrect username or password, you have 1 more chances';
    case '数量精度错误':
      return 'Quantity precision error';
    case '下单数量小于最小限制数量':
      return 'The order quantity is less than the minimum limit quantity';
    case '价格超出设定偏离范围':
      return 'The price is outside the set deviation range';
    case '用户可用余额不足':
      return 'User has insufficient available balance';
    case '下单金额小于最小限制金额':
      return 'The order amount is less than the minimum limit amount';
    case '预计成交价格高于强平价格，无法下单':
      return 'The expected transaction price is higher than the liquidation price, and the order cannot be placed';
    case '平仓超出仓位总量':
      return 'Closing the position exceeds the total amount of the position';
    default:
      return text;
  }
}
