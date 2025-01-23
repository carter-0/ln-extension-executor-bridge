import { requireNativeModule } from 'expo-modules-core';
import { ExtensionContext, ExtensionResult, LnExtensionExecutorBridgeModule } from './LnExtensionExecutorBridge.types';

const NativeLnExtensionExecutorBridge = requireNativeModule('LnExtensionExecutorBridge') as LnExtensionExecutorBridgeModule;

export default {
  executeExtension: async (context: ExtensionContext): Promise<ExtensionResult> => {
    return await NativeLnExtensionExecutorBridge.executeExtension(context);
  },
  
  isExtensionAvailable: async (bundleIdentifier: string): Promise<boolean> => {
    return await NativeLnExtensionExecutorBridge.isExtensionAvailable(bundleIdentifier);
  }
};
