import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

export type Props = {
  // No props needed since this is just a placeholder
}

const NativeView = requireNativeViewManager('LnExtensionExecutorBridge');

export default function LnExtensionExecutorBridgeView(props: Props) {
  return <NativeView {...props} />;
} 