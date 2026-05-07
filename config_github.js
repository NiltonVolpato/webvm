// The root filesystem location
export const diskImageUrl = IMAGE_URL;
// The root filesystem backend type
export const diskImageType = "github";
// Print an introduction message about the technology
export const printIntro = true;
// Is a graphical display needed
export const needsDisplay = false;
// Executable full path (Required)
export const cmd = "/bin/bash";
// Arguments, as an array (Required)
export const args = ["--login"];
// Optional extra parameters
export const opts = {
  // Environment variables
  env: [
    "HOME=/home/user",
    "TERM=xterm",
    "USER=user",
    "SHELL=/bin/bash",
    "EDITOR=mg",
    "LANG=en_US.UTF-8",
    "LC_ALL=en_US.UTF-8",
  ],
  // Current working directory
  cwd: "/home/user",
  // User id
  uid: 1000,
  // Group id
  gid: 1000,
};
// Web device base path (relative to the web server root)
export const webDevicePath = "";
