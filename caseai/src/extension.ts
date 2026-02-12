// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';
import * as cp from 'child_process';

// Create output channel
const outputChannel = vscode.window.createOutputChannel('caseAI');

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {

	// Use the console to output diagnostic information (console.log) and errors (console.error)
	// This line of code will only be executed once when your extension is activated
	console.log('Congratulations, your extension "caseai" is now active!');

	// Register command to run symsmtrunner
	const disposable = vscode.commands.registerCommand('caseai.runSymsmtrunner', async () => {
		const editor = vscode.window.activeTextEditor;
		
		if (!editor) {
			vscode.window.showErrorMessage('No file is currently open');
			return;
		}

		const filePath = editor.document.uri.fsPath;

		// Hardcoded path to symsmtrunner
		const symsmtrunnerPath = context.asAbsolutePath('../out/symsmtrunner');
		const symsmtrunnerDir = context.asAbsolutePath('../');

		outputChannel.clear();
		outputChannel.show(true);
		outputChannel.appendLine(`Running symsmtrunner on: ${filePath}\n`);

		try {
			cp.execFile(symsmtrunnerPath, [filePath], { cwd: symsmtrunnerDir }, (error, stdout, stderr) => {
				if (error) {
					outputChannel.appendLine(`Error: ${error.message}`);
					if (stderr) {
						outputChannel.appendLine(`stderr: ${stderr}`);
					}
					vscode.window.showErrorMessage(`Failed to run symsmtrunner: ${error.message}`);
					return;
				}

				if (stdout) {
					outputChannel.appendLine(stdout);
				}
				if (stderr) {
					outputChannel.appendLine(`stderr: ${stderr}`);
				}

				vscode.window.showInformationMessage('symsmtrunner completed successfully');
			});
		} catch (error) {
			const errorMsg = error instanceof Error ? error.message : String(error);
			outputChannel.appendLine(`Exception: ${errorMsg}`);
			vscode.window.showErrorMessage(`Failed to execute symsmtrunner: ${errorMsg}`);
		}
	});

	context.subscriptions.push(disposable);
}

// This method is called when your extension is deactivated
export function deactivate() {}
