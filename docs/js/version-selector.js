// Links work without JavaScript. Preserve page context only when it exists in
// the destination version; a missing page falls back to that version's homepage.
document.addEventListener("toggle", (event) => {
  const menu = event.target;
  if (!(menu instanceof HTMLDetailsElement) ||
      !menu.matches("[data-version-selector]") || !menu.open) return;

  let anchor = "";
  try {
    anchor = decodeURIComponent(window.location.hash.slice(1));
  } catch {
    // A malformed URL fragment should not prevent switching versions.
  }
  for (const link of menu.querySelectorAll("a")) {
    const target = new URL(link.href);
    const samePage = link.dataset.samePage === "true";
    target.search = samePage ? window.location.search : "";
    target.hash = samePage && JSON.parse(link.dataset.anchors).includes(anchor)
      ? window.location.hash : "";
    link.href = target.href;
  }
}, true);

// Clicking or moving keyboard focus out of the menu dismisses it without
// moving focus away from the user's new target.
for (const type of ["click", "focusin"]) {
  document.addEventListener(type, (event) => {
    for (const menu of document.querySelectorAll("[data-version-selector][open]")) {
      const selected = type === "click" && event.target instanceof Element
        && event.target.closest("a");
      if (!menu.contains(event.target) || selected) menu.open = false;
    }
  });
}

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return;
  const menu = event.target.closest("[data-version-selector]");
  if (menu && menu.open) {
    menu.open = false;
    menu.querySelector("summary").focus();
  }
});
