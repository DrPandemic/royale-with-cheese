import Plotly from "plotly.js-dist";
import moment from "moment";
import qs from "qs"

import {chunk} from "./sanitize";
import {boxplot7D, layout} from "./boxplot";
import {getUrlParam} from "./topBar";

export async function displayGraph() {
  const result = await fetchData();
  showItemInfo(result);
  let data;
  switch(getDuration()) {
  case "1d":
    data = boxplot7D(chunk(result.entries, 1, moment.utc().startOf("day")), "MMM D, kk:00");
    break;
  case "7d":
    data = boxplot7D(chunk(result.entries, 7, moment.utc().startOf("day")), "MMM D");
    break;
  case "30d":
    data = boxplot7D(chunk(result.entries, 30, moment.utc().startOf("day")), "MMM D");
    break;
  }

  Plotly.newPlot('boxplot-chart', data, layout);
}

function redirectToIndex() {
  if (window.location.pathname !== "/") {
    window.location.href = "/";
  }
}

function getDuration() {
  const menu = document.getElementById("graph-duration");
  if (menu) {
    return menu.options[menu.selectedIndex].value;
  }
  return "0";
}

async function fetchData() {
  const region = getUrlParam("region");
  const realm = getUrlParam("realm");
  const itemName = getUrlParam("item_name");
  const params = qs.stringify({region: region, realm: realm, item_name: itemName, duration: getDuration()});
  return fetch(`/api/items?${params}`).then(r => r.json()).catch(redirectToIndex);
}

function showItemInfo(result) {
  const info = document.getElementById("item-info");
  const icon = document.getElementById("item-icon");
  const name = document.getElementById("item-name-display");

  info.style.display = "";
  icon.src = getIconURL(result.item.icon);
  name.innerText = result.item.name;

  const count = document.getElementById("item-count");
  if (result.entries.data.length == result.entries.initial_count) {
    count.innerText = `${result.entries.data.length} auction entries were analyzed.`;
  } else {
    count.innerText = `${result.entries.data.length} auction entries were analyzed. They were randomly sampled from ${result.entries.initial_count} entries.`;
  }
}

export function getIconURL(icon) {
  return `/images/blizzard/icons/36/${icon}.jpg`
}
