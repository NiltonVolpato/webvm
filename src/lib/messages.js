const color = "\x1b[1;35m";
const underline = "\x1b[94;4m";
const normal = "\x1b[0m";
// Formats as a link.
function l(str) {
  return `${underline}${str}${normal}`;
}
// Formats with emphasis (color).
function e(str) {
  return `${color}${str}${normal}`;
}
export const introMessage = [
  "",
  "  Welcome back, Nilton",
  "  ...you're Nilton, right?",
  "",
];
export const errorMessage = [
  e("Terminal failed to start"),
  "",
  "Check the DevTools console for more information",
  "",
  "Be sure you're on a recent version of Chrome, Edge, Firefox or Safari",
  "",
  "Internal error (from CheerpX):",
  "",
];
export const unexpectedErrorMessage = [
  e("Unexpected error"),
  "",
  "Check the DevTools console for more information",
  "",
  "Consider reporting a bug!",
  "Internal error (from CheerpX):",
  "",
];
