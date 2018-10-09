import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

void main() {
  // Find port to listen on from environment variable.
  var port = int.tryParse(Platform.environment['PORT']);
  
  // Read $TARGET from environment variable.
  var target = Platform.environment['TARGET'] ?? 'World';

  // Create handler.
  var handler = Pipeline().addMiddleware(logRequests()).addHandler((request) {
    return Response.ok('Hello $target');
  });

  // Serve handler on given port.
  serve(handler, InternetAddress.anyIPv4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
