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
      container.removeChild(container.firstChild);
    }

    for (const item of items) {
      const template = document.getElementById("recommendation-template").cloneNode(true);
      template.id = "";
      template.style.display = "";

      const icon = template.getElementsByClassName("recommendation-icon")[0];
      icon.src = getIconURL(item.icon);

      const nameTemplate = template.getElementsByClassName("recommendation-name")[0];
      nameTemplate.innerText = item.name;

      container.appendChild(template);
    }
  }, 500);
}
