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
        
        AsyncFunction("listExtensions") { (promise: Promise) in
            let shareExtensionPoint = "com.apple.share-services"
            
            // Get all installed app bundles
            guard let installedApps = Bundle.main.bundleIdentifier.flatMap({ Bundle(identifier: $0) }) else {
                promise.reject("ERR_LIST_FAILED", "Failed to get list of extensions")
                return
            }
            
            // Get the extension info from Info.plist
            guard let extensionsInfo = installedApps.infoDictionary?["NSExtension"] as? [String: Any],
                  let extensionPoint = extensionsInfo["NSExtensionPointIdentifier"] as? String,
                  extensionPoint == shareExtensionPoint else {
                promise.resolve([]) // No share extensions found
                return
            }
            
            let result: [[String: Any]] = [
                [
                    "bundleIdentifier": installedApps.bundleIdentifier ?? "",
                    "name": installedApps.infoDictionary?["CFBundleDisplayName"] as? String ?? "",
                    "extensionPointIdentifier": shareExtensionPoint
                ]
            ]
            
            promise.resolve(result)
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
