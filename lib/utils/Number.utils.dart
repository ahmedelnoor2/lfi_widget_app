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
