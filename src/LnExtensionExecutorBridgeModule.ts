import { requireNativeModule } from 'expo-modules-core';
import { ExtensionContext, ExtensionItem, ExtensionResult, LnExtensionExecutorBridgeModule } from './LnExtensionExecutorBridge.types';

const NativeLnExtensionExecutorBridge = requireNativeModule('LnExtensionExecutorBridge') as LnExtensionExecutorBridgeModule;

export default {
  executeExtension: async (context: ExtensionContext): Promise<ExtensionResult> => {
    return await NativeLnExtensionExecutorBridge.executeExtension(context);
  },
  
  listExtensions: async (): Promise<ExtensionItem[]> => {
    return await NativeLnExtensionExecutorBridge.listExtensions();
  },
  
  isExtensionAvailable: async (bundleIdentifier: string): Promise<boolean> => {
    return await NativeLnExtensionExecutorBridge.isExtensionAvailable(bundleIdentifier);
  }
};
