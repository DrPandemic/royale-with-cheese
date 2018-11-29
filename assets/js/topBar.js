import qs from "qs";
import {getIconURL} from "./graph";

export function preselectForm() {
  selectDropdown(document.getElementById("region"), getUrlParam("region"));
  selectDropdown(document.getElementById("realm"), getUrlParam("realm"));
  document.getElementById("item-name").value = getUrlParam("item_name");
}

export function getUrlParam(key) {
  const url = window.location.search.substr(1);

  return qs.parse(url)[key];
}

function selectDropdown(menu, value) {
  for (const i in menu.options) {
    if (menu.options[i].value === value) {
      menu.options[i].selected = true;
    }
  }
}

let debounce;
const recommendationURL = "/api/items/find?";
export function fillSearchRecommendation() {
  if (debounce) {
    clearTimeout(debounce);
  }
  debounce = setTimeout(async () => {
    const name = document.getElementById("item-name").value;
    const items = await fetch(`${recommendationURL}${qs.stringify({item_name: name})}`).then(r => r.json())

    const container = document.getElementById("recommendation-box");
    while (container.firstChild) {
      container.firstChild.removeEventListener("click", recommendationClick);
      container.removeChild(container.firstChild);
    }

    if (items.length > 0) {
      hideOnClickOutside(container);
      container.style.display = "";
    } else {
      container.style.display = "none";
    }

    for (const item of items) {
      const newNode = document.getElementById("recommendation-template").cloneNode(true);
      newNode.addEventListener("click", recommendationClick);
      newNode.id = "";
      newNode.style.display = "";

      const icon = newNode.getElementsByClassName("recommendation-icon")[0];
      icon.src = getIconURL(item.icon);

      const nameTemplate = newNode.getElementsByClassName("recommendation-name")[0];
      nameTemplate.innerText = item.name;

      container.appendChild(newNode);
    }
  }, 500);
}

// https://stackoverflow.com/a/3028037/1779927
function hideOnClickOutside(element) {
  const isVisible = (elem) => !!elem && !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
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
  console.log(e);
}
