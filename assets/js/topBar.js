import qs from "qs";
import {getIconURL} from "./graph";

const regions = {
  eu: ["Kazzak", "Medivh", "Suramar"],
  us: ["Medivh", "Exodar"],
};
const recommendationContainer = document.getElementById("recommendation-box");

export function preselectForm() {
  fillRegion();
  fillRealm();
  selectDropdown(document.getElementById("region"), getUrlParam("region"));
  selectDropdown(document.getElementById("realm"), getUrlParam("realm"));
  document.getElementById("item-name").value = getUrlParam("item_name") || "";
}

export function getUrlParam(key) {
  const url = window.location.search.substr(1);

  return qs.parse(url)[key];
}

function selectDropdown(menu, value) {
  for (const option of menu.options) {
    if (option.value === value) {
      option.selected = true;
    }
  }
}

function getDropdownValue(menu) {
  for (const option of menu.options) {
    if (option.selected) {
      return option.value;
    }
  }
  return "";
}

function fillRegion() {
  const menu = document.getElementById("region");
  while (menu.firstChild) {
    menu.removeChild(menu.firstChild);
  }
  for (const region of Object.keys(regions)) {
    const option = document.createElement("option");
    option.value = region;
    option.innerHTML = region.toUpperCase();
    menu.appendChild(option);
  }
}

export function fillRealm() {
  const menu = document.getElementById("realm");
  while (menu.firstChild) {
    menu.removeChild(menu.firstChild);
  }
  for (const realm of regions[getMenuRegion()]) {
    const option = document.createElement("option");
    option.value = realm;
    option.innerHTML = realm;
    menu.appendChild(option);
  }
}

function getMenuRealm() {
  return getDropdownValue(document.getElementById("realm"));
}

function getMenuRegion() {
  return getDropdownValue(document.getElementById("region"));
}

let debounce;
const recommendationURL = "/api/items/find?";
export function fillSearchRecommendation() {
  if (debounce) {
    clearTimeout(debounce);
  }
  debounce = setTimeout(async () => {
    const name = document.getElementById("item-name").value;
    if (name === "") {
      return;
    }
    const items = await fetch(`${recommendationURL}${qs.stringify({item_name: name})}`).then(r => r.json())

    while (recommendationContainer.firstChild) {
      recommendationContainer.firstChild.removeEventListener("click", recommendationClick);
      recommendationContainer.removeChild(recommendationContainer.firstChild);
    }

    if (items.length > 0) {
      hideOnClickOutside(recommendationContainer);
      recommendationContainer.style.display = "";
    } else {
      recommendationContainer.style.display = "none";
    }
    recommendationContainer.scrollTop = 0;

    for (const item of items) {
      const newNode = document.getElementById("recommendation-template").cloneNode(true);
      newNode.addEventListener("click", recommendationClick);
      newNode.id = "";
      newNode.style.display = "";

      const icon = newNode.getElementsByClassName("recommendation-icon")[0];
      icon.src = getIconURL(item.icon);

      const nameTemplate = newNode.getElementsByClassName("recommendation-name")[0];
      nameTemplate.innerText = item.name;
      newNode.dataset.itemName = item.name;

      recommendationContainer.appendChild(newNode);
    }
  }, 500);
}

function isVisible(elem) {
  return !!elem && !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
}

// https://stackoverflow.com/a/3028037/1779927
function hideOnClickOutside(element) {
  const outsideClickListener = (event) => {
    if (!element.contains(event.target) && event.target.id !== "item-name") {
      if (isVisible(element)) {
        element.style.display = "none";
        document.removeEventListener("click", outsideClickListener);
        clearTimeout(debounce);
      }
    }
  }

  document.addEventListener("click", outsideClickListener);
}

function recommendationClick(e) {
  const itemName = e.target.closest(".recommendation-row").dataset.itemName;
  gotoItem(itemName);
}

function gotoItem(itemName) {
  const params = {
    item_name: itemName,
    region: getMenuRegion(),
    realm: getMenuRealm(),
  };
  window.location.href = `/items?${qs.stringify(params)}`;
}

export function registerArrows() {
  document.onkeydown = onKeyDown;
}

function onKeyDown(e) {
  if (!isVisible(recommendationContainer) || !['ArrowUp', 'ArrowDown', 'Enter'].includes(e.key)) {
    return;
  }
  const index = Array.from(recommendationContainer.childNodes).findIndex(c => c.classList.contains('selected'));
  let nextIndex = 0;

  switch(e.key) {
  case 'ArrowUp':
    nextIndex = (index - 1) < 0 ? recommendationContainer.childNodes.length - 1 : index - 1;
    break;
  case 'ArrowDown':
    nextIndex = (index + 1) % recommendationContainer.childNodes.length;
    break;
  case 'Enter':
    if (index !== -1) {
      e.preventDefault();
    }
    gotoItem(recommendationContainer.childNodes[index].dataset.itemName);
    return;
  }

  // Change classes
  for(const e of recommendationContainer.childNodes) {
    e.classList.remove('selected');
  }
  recommendationContainer.childNodes[nextIndex].classList.add('selected');

  // Scroll recommendation
  // The result is not super natural, but good enough.
  recommendationContainer.scrollTop = recommendationContainer.childNodes[nextIndex].offsetTop;
}
