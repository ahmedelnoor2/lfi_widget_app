import 'package:flutter/foundation.dart' show kIsWeb;

var height;
var width;
var currentindex = 0;

var apiUrl = kIsWeb ? 'api.m.lyotrade.com' : 'www.lyotrade.com';
var lyoApiUrl = 'api.m.lyotrade.com';
var futApiUrl = 'futures.lyotrade.com';
var serviceApi = kIsWeb ? 'api.m.lyotrade.com' : 'service.lyotrade.com';
var loanApiUrl = 'staging.api.crypto-loan.lyotrade.com';
var paymentsApi = 'payments.lyotrade.com';
var apiurlemailtoken = 'api.dash.lyotrade.com';
var changeNowApi = 'https://content-api.changenow.io';
var referralinvitation = '/fe-increment-api/invitation';
//var referralbaseurl = 'https://www.lyotrade.com';
var referral = '/fe-ex-api/agentV2';

var exApi = kIsWeb ? '/api/fe-ex-api' : '/fe-ex-api';
var lyoPubApi = '/api';
var fePubApi = kIsWeb ? '/api' : '/';
var futExApi = '/fe-co-api';
var plfApi = kIsWeb ? '/service/fe-platform-api' : '/fe-platform-api';
var loanApiVersion = '/loans';
var loansApiestimate = '/loans/estimate';
var loanhistory = '/mstloan';
var getemailverifytoken = '/customers';
var profileuser='/user-avatar';
var getfavmarkert = '/admin';
var incrementApi = kIsWeb ? '/api/fe-increment-api' : '/fe-increment-api';
var openApiUrl = 'openapi.lyotrade.com';

var dexSwapApi = kIsWeb ? 'api.m.lyotrade.com' : 'api.changenow.io';
var exDexSwap = kIsWeb ? '/changenow' : '';
var dexApiKey =
    'a4643d07a4ae7c79183e95e53da2fa17c3f2307e901c1b440083b1f0c9a32cc5';
