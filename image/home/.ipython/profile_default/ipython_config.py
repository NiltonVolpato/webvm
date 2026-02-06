# IPython configuration

c = get_config()  # noqa: F821

c.TerminalInteractiveShell.colors = 'Linux'

# Auto-indent
c.TerminalInteractiveShell.autoindent = True

# Show rewritten input (e.g., for %timeit)
c.TerminalInteractiveShell.show_rewritten_input = True

# Confirm exit
c.TerminalInteractiveShell.confirm_exit = False

# Enable autoreload for development
c.InteractiveShellApp.extensions = ['autoreload']
c.InteractiveShellApp.exec_lines = ['%autoreload 2']

# Banner
c.TerminalInteractiveShell.banner1 = ''
c.TerminalInteractiveShell.banner2 = ''
