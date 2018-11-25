import qs from "qs"

export function preselectForm() {
  selectDropdown(document.getElementById("region"), getUrlParam("region"));
  selectDropdown(document.getElementById("realm"), getUrlParam("realm"));
  document.getElementById("item_name").value = getUrlParam("item_name");
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
