String getTranslate(String text) {
  switch (text) {
    case '发送过于频繁，稍后再试':
      return 'Sending too often, try again later';
    default:
      return text;
  }
}
