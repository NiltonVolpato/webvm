// OSC escape sequence handlers for WebVM
// Allows triggering UI panels and file operations from within the VM
// Usage: printf '\e]7337;open:network\a'       (open a UI panel)
//        printf '\e]7337;filepicker\a'          (open browser file picker → /data)
//        printf '\e]7337;download:filename\a'   (trigger browser download from /uploads)

export function registerOscHandlers(term, panelCallback, { uploadDeviceGetter }) {
	// OSC 7337 - WebVM custom escape sequences
	// Format: \e]7337;command:arg\a
	term.parser.registerOscHandler(7337, async (data) => {
		const colonIndex = data.indexOf(':');
		const command = colonIndex >= 0 ? data.substring(0, colonIndex) : data;
		const arg = colonIndex >= 0 ? data.substring(colonIndex + 1) : '';

		switch (command) {
			case 'open':
				if (['network', 'claude', 'cpu', 'disk', 'upload'].includes(arg)) {
					panelCallback(arg);
					return true;
				}
				return false;
			case 'close':
				panelCallback(null);
				return true;
			case 'filepicker':
				panelCallback('upload', { sessionId: arg || null });
				return true;
			case 'download':
				// Trigger browser download of a file staged in /uploads
				if (arg && uploadDeviceGetter) {
					try {
						const uploadDevice = uploadDeviceGetter();
						if (!uploadDevice) return false;

						const filename = arg.split('/').pop() || 'download';
						const blob = await uploadDevice.readFileAsBlob('/' + filename);
						const url = URL.createObjectURL(blob);

						const a = document.createElement('a');
						a.href = url;
						a.download = filename;
						a.click();

						URL.revokeObjectURL(url);
						return true;
					} catch (e) {
						console.error('Download failed:', e);
						return false;
					}
				}
				return false;
			default:
				return false;
		}
	});
}
