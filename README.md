# WebVM

A Linux virtual machine that runs in your browser, powered by CheerpX.

WebVM is a server-less virtual environment running fully client-side in HTML5/WebAssembly. It's designed to be Linux ABI-compatible and runs an unmodified Debian distribution including native development toolchains.

## Features

- **Full Linux environment** - Run bash, Python, gcc, and more
- **Networking via Tailscale** - Connect to your private network or the internet
- **Claude AI integration** - Get AI assistance directly in the terminal
- **File transfer** - Download files into the VM, upload files from the VM
- **OSC escape sequences** - Control the UI from within the VM

## Enable Networking

Modern browsers do not provide APIs to directly use TCP or UDP. WebVM provides networking support by integrating with Tailscale, a VPN network that supports WebSockets as a transport layer.

1. Open the "Networking" panel from the status bar
2. Click "Connect to Tailscale"
3. Log in to Tailscale (create an account if you don't have one)
4. Click "Connect" when prompted

### Accessing the Internet

To access the public internet, set up an Exit Node on one of your Tailscale network devices. See the [Tailscale Exit Node guide](https://tailscale.com/kb/1408/quick-guide-exit-nodes?tab=linux) for instructions.

> **Note:** Some commands that rely on kernel-level features (like `ping`) are not supported. Use `curl` or `wget` for testing connectivity.

### Using an Auth Key

As an alternative to manual login, add your Tailscale auth key to the URL:

```
https://your-webvm-url/#authKey=<your-key>
```

Use an ephemeral key for security.

### Self-hosting with Headscale

WebVM supports [Headscale](https://headscale.net/stable/), a self-hosted Tailscale control server. You'll need to set up a proxy to add CORS headers. See the [Headscale reverse proxy docs](https://headscale.net/stable/ref/integration/reverse-proxy/#nginx).

Add to your nginx config:

```nginx
if ($http_origin = "https://your-webvm-url") {
    add_header 'Access-Control-Allow-Origin' "$http_origin";
    add_header 'Access-Control-Allow-Credentials' 'true' always;
}
```

Then add `#controlUrl=<your-control-url>` to the WebVM URL.

## File Transfer

### Downloading Files into the VM

Use the `download` script or click the download icon in the status bar to pick a file from your browser:

```bash
download              # Save to current directory
download /home/user/  # Save to specific directory
```

> **Note:** Files stage through `/data/` (volatile). The `download` script automatically copies them to the destination.

### Uploading Files from the VM

Use the `upload` script to send a file from the VM to your browser:

```bash
upload myfile.txt
```

## OSC Escape Sequences

WebVM supports custom OSC (Operating System Command) escape sequences to control the UI from within the VM.

### OSC 7337 - WebVM Commands

```bash
# Panel control
printf '\e]7337;open:network\a'   # Open Networking panel
printf '\e]7337;open:claude\a'    # Open Claude AI panel
printf '\e]7337;open:cpu\a'       # Open CPU activity panel
printf '\e]7337;open:disk\a'      # Open Disk panel
printf '\e]7337;close\a'          # Close current panel
```

This allows shell scripts and programs to trigger UI interactions.

## Claude AI Integration

To use Claude AI assistance:

1. Get an API key from [Anthropic Console](https://console.anthropic.com/)
2. Click the robot icon in the status bar
3. Enter your API key
4. Start asking questions about your system or code

Your API key is stored locally in your browser and is never sent to any server other than Anthropic's API.

## Running Locally

### 1. Clone and setup

```sh
git clone <your-repo-url>
cd webvm
npm install
```

### 2. Download a disk image

```sh
wget "https://github.com/leaningtech/webvm/releases/download/ext2_image/debian_mini_20230519_5022088024.ext2"
mkdir disk-images
mv debian_mini_20230519_5022088024.ext2 disk-images/
```

### 3. Update config

Edit `config_public_terminal.js`:
- Change the disk URL to `/disk-images/debian_mini_20230519_5022088024.ext2`
- Change disk type from `"cloud"` to `"bytes"`

### 4. Build and serve

```sh
npm run build
nginx -p . -c nginx.conf
```

Visit `http://127.0.0.1:8081`

## Customization

Modify `dockerfiles/debian_mini` to customize the disk image, or create a new Dockerfile. See the [CheerpX custom images documentation](https://cheerpx.io/docs/guides/custom-images).

## Dependencies

- [CheerpX](https://cheerpx.io/) - x86 virtualization and Linux emulation
- [xterm.js](https://xtermjs.org/) - Web-based terminal emulator
- [Tailscale](https://tailscale.com/) - Networking
- [lwIP](https://savannah.nongnu.org/projects/lwip/) - TCP/IP stack

## License

WebVM is released under the Apache License, Version 2.0.

CheerpX licensing: The public CheerpX deployment is free for personal use. Commercial use requires a license. See [CheerpX licensing](https://cheerpx.io/docs/licensing).
