import 'package:scale_framework/resources/http/interceptors.dart';

void Function(String) scaleDebugPrint = (p0) {};

HttpRequestInterceptor Function(HttpRequestInterceptor interceptor)
    httpInterceptorDecorator = (interceptor) => interceptor;
