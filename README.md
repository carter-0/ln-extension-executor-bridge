# ln-extension-executor-bridge

An Expo native module wrapping [LNExtensionExecutor](https://github.com/LeoNatan/LNExtensionExecutor/tree/master). Allows bypassing UIActivityViewController to execute both UI and non-UI action extensions.

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/LeoNatan/LNExtensionExecutor/master/LICENSE)

## Adding to Your Project

1. Create a new Expo native module in your app
    - `npx create-expo-module ln-extension-executor-bridge`

2. Delete all files in `modules/ln-extension-executor-bridge`:
    - `rm -rf modules/ln-extension-executor-bridge/*`

3. Clone this repo into the `modules/ln-extension-executor-bridge` directory. You can delete README.md and LICENSE.
    - `cd modules/ln-extension-executor-bridge && git clone https://github.com/carter-0/ln-extension-executor-bridge.git .`
    - `rm README.md LICENSE`

That's it! It's not the most elegent installation and it could definitely be improved by making it a real package but I spent so long getting this to work that I'm not touching it for now.

## Usage

Make sure to re-build your app before usage.

Import the module:
```typescript
import LnExtensionExecutorBridgeModule from "../modules/ln-extension-executor-bridge/src/LnExtensionExecutorBridgeModule"
```

### API Methods

#### executeExtension
Executes an iOS extension with the given context.

```typescript
async function executeExtension(context: ExtensionContext): Promise<ExtensionResult>
```

Parameters:
- `context`: An object containing:
  - `bundleIdentifier`: The bundle ID of the extension to execute
  - `extensionPointIdentifier` (optional): The extension point ID
  - `activityItems` (optional): Array of items to pass to the extension

Returns:
- `ExtensionResult`: Object containing:
  - `completed`: Boolean indicating if execution completed
  - `returnItems`: Array of items returned from the extension

#### listExtensions
Lists all available extensions.

```typescript
async function listExtensions(): Promise<ExtensionItem[]>
```

Returns array of `ExtensionItem` objects containing:
- `bundleIdentifier`: Extension's bundle ID
- `name`: Extension name
- `extensionPointIdentifier`: Extension point ID

#### isExtensionAvailable
Checks if an extension is available.

```typescript
async function isExtensionAvailable(bundleIdentifier: string): Promise<boolean>
```

Parameters:
- `bundleIdentifier`: Bundle ID to check

Returns boolean indicating availability.

### Example Usage

```typescript
// Check if extension exists
const available = await LnExtensionExecutorBridgeModule.isExtensionAvailable(
  "com.burbn.instagram.shareextension"
);

// List all extensions
const extensions = await LnExtensionExecutorBridgeModule.listExtensions();

// Execute an extension
const result = await LnExtensionExecutorBridgeModule.executeExtension({
  bundleIdentifier: "com.burbn.instagram.shareextension",
  activityItems: ["https://www.google.com"]
});
```

## Bundle IDs

These can be hard to find so here's a list of some common ones to help you out :)

- `com.burbn.instagram.shareextension`: Instagram
- `com.toyopagroup.picaboo.share`: Snapchat
- `net.whatsapp.WhatsApp.ShareExtension`: WhatsApp
- `com.facebook.Messenger.ShareExtension`: Facebook Messenger
- `ph.telegra.Telegraph.Share`: Telegram
- `com.iwilab.KakaoTalk.Share`: KakaoTalk
- `jp.naver.line.Share`: LINE

## License

MIT
