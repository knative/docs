import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future main() async {
  // Find port to listen on from environment variable.
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  // Read $TARGET from environment variable.
  var target = Platform.environment['TARGET'] ?? 'World';

  Response handler(Request request) => Response.ok('Hello $target');

  // Serve handler on given port.
  var server = await serve(
    Pipeline().addMiddleware(logRequests()).addHandler(handler),
    InternetAddress.anyIPv4,
    port,
  );
  print('Serving at http://${server.address.host}:${server.port}');
}
