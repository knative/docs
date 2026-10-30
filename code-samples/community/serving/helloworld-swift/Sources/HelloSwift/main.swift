import Foundation
import Hummingbird

let configuration = try Configuration(environment: ProcessInfo.processInfo.environment)
let router = Router()
router.get("/") { _, _ in
  greeting(target: configuration.target)
}
router.post("/") { _, _ in
  greeting(target: configuration.target)
}
let app = Application(
  router: router,
  configuration: .init(address: .hostname("0.0.0.0", port: configuration.port))
)
try await app.runService()
