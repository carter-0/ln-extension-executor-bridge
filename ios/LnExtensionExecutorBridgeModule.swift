import ExpoModulesCore
import Foundation
import MobileCoreServices

let LNExtensionExecutorErrorDomain = "LNExtensionExecutorErrorDomain"
let LNExtensionNotFoundErrorCode = 6001

public class LnExtensionExecutorBridgeModule: Module {
    public func definition() -> ModuleDefinition {
        Name("LnExtensionExecutorBridge")

        AsyncFunction("executeExtension") { (context: [String: Any], promise: Promise) in
            guard let bundleIdentifier = context["bundleIdentifier"] as? String else {
                promise.reject("ERR_INVALID_BUNDLE", "Bundle identifier is required")
                return
            }
            
            guard let viewController = self.appContext?.utilities?.currentViewController() else {
                promise.reject("ERR_NO_VIEWCONTROLLER", "No view controller available")
                return
            }
            
            guard let rawActivityItems = context["activityItems"] as? [Any] else {
                promise.reject("ERR_INVALID_ACTIVITY_ITEMS", "Activity items must be an array")
                return
            }
            
            let activityItems = rawActivityItems.compactMap { item -> Any? in
                if let str = item as? String { return str }
                if let url = item as? URL { return url }
                if let data = item as? Data { return data }
                if let image = item as? UIImage { return image }
                return nil
            }
            
            if activityItems.isEmpty && !rawActivityItems.isEmpty {
                promise.reject("ERR_INVALID_ACTIVITY_ITEMS", "Activity items must be of type String, URL, Data, or UIImage")
                return
            }
            
            Task { @MainActor in
                do {
                    let executor = try LNExtensionExecutor(extensionBundleIdentifier: bundleIdentifier)
                    
                    let result = await withCheckedContinuation { continuation in
                        executor.execute(withActivityItems: activityItems, on: viewController) { isCompleted, items, error in
                            continuation.resume(returning: (isCompleted, items, error))
                        }
                    }
                    
                    let (completed, returnItems, executionError) = result
                    
                    if let error = executionError {
                        switch (error as NSError).domain {
                        case LNExtensionExecutorErrorDomain where (error as NSError).code == LNExtensionNotFoundErrorCode:
                            promise.reject("ERR_EXTENSION_NOT_FOUND", "Extension is not installed on the current device")
                        case LNExtensionExecutorErrorDomain:
                            promise.reject("ERR_EXTENSION_ERROR", "Extension error: \(error.localizedDescription)")
                        default:
                            promise.reject("ERR_EXECUTION_FAILED", "Execution failed: \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    promise.resolve([
                        "completed": completed,
                        "returnItems": returnItems ?? []
                    ])
                } catch {
                    promise.reject("ERR_EXECUTION_FAILED", error.localizedDescription)
                }
            }
        }
        
        AsyncFunction("isExtensionAvailable") { (bundleIdentifier: String, promise: Promise) in
            do {
                // Try to create an executor with the bundle ID - if it succeeds, the extension is available
                _ = try LNExtensionExecutor(extensionBundleIdentifier: bundleIdentifier)
                promise.resolve(true)
            } catch {
                promise.resolve(false)
            }
        }
    }
}
