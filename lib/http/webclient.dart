import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import 'interceptors/loggin_interceptors.dart';


const String baseUrl = 'http://10.0.0.181:8080/transactions';

Client client = InterceptedClient.build(interceptors: [LoggingInterceptor()]);


