import Swifter
import Dispatch
import Foundation

let server = HttpServer()
server["/"] = { r in  
    let target = ProcessInfo.processInfo.environment["TARGET"] ?? "World"
    return HttpResponse.ok(.html("Hello \(target)"))
}

let semaphore = DispatchSemaphore(value: 0)
do {
    let port = UInt16(ProcessInfo.processInfo.environment["PORT"] ?? "8080")
    try server.start(port!, forceIPv4: true)
    print("Server has started ( port = \(try server.port()) ). Try to connect now...")
    semaphore.wait()
} catch {
    print("Server start error: \(error)")
    semaphore.signal()
}
