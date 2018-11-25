import Plotly from "plotly.js-dist";
import moment from "moment";
import {chunk} from "./sanitize";
import {boxplot7D, layout} from "./boxplot";
import {getUrlParam} from "./topBar";

const iconURL = "/images/blizzard/icons/36/";

export async function displayGraph() {
  const result = await fetchData();
  showItemInfo(result);
  let data;
  switch(getDuration()) {
  case "1d":
    data = boxplot7D(chunk(result.entries, 1, moment.utc()), "MMM D, kk:00");
    break;
  case "7d":
    data = boxplot7D(chunk(result.entries, 7, moment.utc()), "MMM D Y");
    break;
  case "30d":
    data = boxplot7D(chunk(result.entries, 30, moment.utc()), "MMM D Y");
    break;
  }

  Plotly.newPlot('boxplotChart', data, layout);
}

function getDuration() {
  const menu = document.getElementById("graph_duration");
  return menu.options[menu.selectedIndex].value;
}

async function fetchData() {
  const region = getUrlParam("region");
  const realm = getUrlParam("realm");
  const itemName = getUrlParam("item_name");
  return fetch(`/api/items?region=${region}&realm=${realm}&item_name=${itemName}&duration=${getDuration()}`).then(r => r.json());
}

function showItemInfo(result) {
  const info = document.getElementById("item_info");
  const icon = document.getElementById("item_icon");
  const name = document.getElementById("item_name_display");

  info.style.display = "";
  icon.src = `${iconURL}${result.item.icon}.jpg`;
  name.innerText = result.item.name;

  const count = document.getElementById("item_count");
  if (result.entries.data.length == result.entries.initial_count) {
    count.innerText = `${result.entries.data.length} auction entries were analyzed.`;
  } else {
    count.innerText = `${result.entries.data.length} auction entries were analyzed. They were randomly sampled from ${result.entries.initial_count} entries.`;
  }
}
