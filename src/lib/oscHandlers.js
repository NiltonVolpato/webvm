// OSC escape sequence handlers for WebVM
// Allows triggering UI panels and file operations from within the VM
// Usage: printf '\e]7337;open:network\a'
//        printf '\e]7337;filepicker\a'      (open browser file picker → /data)
//        printf '\e]7337;upload:filename\a'  (upload file from VM to browser)

export function registerOscHandlers(term, panelCallback, { cxGetter, uploadDeviceGetter, dataDeviceGetter }) {
	// OSC 7337 - WebVM custom escape sequences
	// Format: \e]7337;command:arg\a
	term.parser.registerOscHandler(7337, async (data) => {
		const colonIndex = data.indexOf(':');
		const command = colonIndex >= 0 ? data.substring(0, colonIndex) : data;
		const arg = colonIndex >= 0 ? data.substring(colonIndex + 1) : '';

		switch (command) {
			case 'open':
				if (['network', 'claude', 'cpu', 'disk'].includes(arg)) {
					panelCallback(arg);
					return true;
				}
				return false;
			case 'close':
				panelCallback(null);
				return true;
			case 'filepicker':
				// Open browser file picker, write file to /data, signal completion
				if (dataDeviceGetter) {
					try {
						const dataDevice = dataDeviceGetter();
						if (!dataDevice) return false;

						const input = document.createElement('input');
						input.type = 'file';
						input.onchange = async (e) => {
							const file = e.target.files?.[0];
							if (!file) return;
							const content = await file.arrayBuffer();
							await dataDevice.writeFile('/' + file.name, new Uint8Array(content));
							// Signal the download script that the file is ready
							await dataDevice.writeFile('/.download_done', file.name);
						};
						input.click();
						return true;
					} catch (e) {
						console.error('File picker failed:', e);
						return false;
					}
				}
				return false;
			case 'upload':
				// Handle VM upload: send file from /uploads to browser
				if (arg && uploadDeviceGetter) {
					try {
						const uploadDevice = uploadDeviceGetter();
						if (!uploadDevice) return false;

						const filename = arg.split('/').pop() || 'file';
						const blob = await uploadDevice.readFileAsBlob('/' + filename);
						const url = URL.createObjectURL(blob);

						const a = document.createElement('a');
						a.href = url;
						a.download = filename;
						a.click();

						URL.revokeObjectURL(url);
						return true;
					} catch (e) {
						console.error('Upload failed:', e);
						return false;
					}
				}
				return false;
			default:
				return false;
		}
	});
}
