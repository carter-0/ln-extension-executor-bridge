export type ExtensionContext = {
  bundleIdentifier: string;
  extensionPointIdentifier?: string;
  activityItems?: any[];
};

export type ExtensionResult = {
  completed: boolean;
  returnItems: any[];
};

export type ExtensionItem = {
  bundleIdentifier: string;
  name: string;
  extensionPointIdentifier: string;
};

export type LnExtensionExecutorBridgeModule = {
  executeExtension(context: ExtensionContext): Promise<ExtensionResult>;
  listExtensions(): Promise<ExtensionItem[]>;
  isExtensionAvailable(bundleIdentifier: string): Promise<boolean>;
};
