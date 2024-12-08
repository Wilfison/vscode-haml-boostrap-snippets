import * as vscode from "vscode";

import CompletionProvider from "./completion_provider";

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.languages.registerCompletionItemProvider(
    { language: 'haml', scheme: 'file' },
    new CompletionProvider(),
    '.',
    '"',
    "'",
  );

  context.subscriptions.push(disposable);
}

export function deactivate() { }
