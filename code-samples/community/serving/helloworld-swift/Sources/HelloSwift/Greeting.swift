import Hummingbird

struct Configuration {
  let target: String
  let port: Int

  enum Error: Swift.Error {
    case invalidPort(String)
  }

  init(environment: [String: String]) throws {
    target = environment["TARGET"] ?? "World"
    let value = environment["PORT"] ?? "8080"
    guard let port = Int(value), (1...65535).contains(port) else {
      throw Error.invalidPort(value)
    }
    self.port = port
  }
}

func greeting(target: String) -> Response {
  Response(
    status: .ok,
    headers: [.contentType: "text/html"],
    body: .init(
      byteBuffer: .init(string: #"<html><meta charset="UTF-8"><body>Hello \#(target)</body></html>"#)
    )
  )
}
