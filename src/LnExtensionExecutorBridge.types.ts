export type ExtensionContext = {
  bundleIdentifier: string;
  extensionPointIdentifier?: string;
  activityItems?: ActivityItem[];
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

export type ActivityItem = {
  type: 'string' | 'file';
  value: string | URL;
};

export type LnExtensionExecutorBridgeModule = {
  executeExtension(context: ExtensionContext): Promise<ExtensionResult>;
  isExtensionAvailable(bundleIdentifier: string): Promise<boolean>;
};
