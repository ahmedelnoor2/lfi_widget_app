import 'package:intl/intl.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:provider/provider.dart';

String getNumberFormat(context, item) {
  var public = Provider.of<Public>(context, listen: false);
  try {
    return NumberFormat.currency(
      locale: "en_US",
      symbol: "${public.activeCurrency['fiat_icon']}",
    ).format(item);
  } catch (e) {
    return NumberFormat.currency(
      locale: "en_US",
      symbol: "${public.activeCurrency['fiat_icon']}",
    ).format(0);
  }
}

String getNumberString(context, item) {
  try {
    if (item.toString().split('.')[0].length > 5) {
      return NumberFormat.compactCurrency(
        locale: "en_US",
        symbol: "",
      ).format(item);
    } else {
      return NumberFormat.currency(
        locale: "en_US",
        symbol: "",
      ).format(item);
    }
  } catch (e) {
    return NumberFormat.currency(
      locale: "en_US",
      symbol: "",
    ).format(0);
  }
}
