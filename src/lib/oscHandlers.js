// OSC escape sequence handlers for WebVM
// Allows triggering UI panels from within the VM via escape sequences
// Usage: printf '\e]7337;open:network\a'

export function registerOscHandlers(term, panelCallback) {
	// OSC 7337 - WebVM custom escape sequences
	// Format: \e]7337;command:arg\a
	term.parser.registerOscHandler(7337, (data) => {
		const parts = data.split(':');
		const command = parts[0];
		const arg = parts[1];

		switch (command) {
			case 'open':
				// Valid panels: network, claude, cpu, disk
				if (['network', 'claude', 'cpu', 'disk'].includes(arg)) {
					panelCallback(arg);
					return true;
				}
				return false;
			case 'close':
				panelCallback(null);
				return true;
			default:
				return false;
		}
	});
}
