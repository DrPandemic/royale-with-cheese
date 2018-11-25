import Plotly from 'plotly.js-dist';
import moment from 'moment';
import {chunk} from './sanitize';
import {boxplot7D, layout} from "./boxplot";

export function displayGraph() {
  const entries = JSON.parse(document.getElementById('boxplotChart').dataset['entries']);
  let data;
  switch(getType()) {
  case "1d":
    data = boxplot7D(chunk(entries, 1, moment.utc()), "MMM D, kk:00");
    break;
  case "7d":
    data = boxplot7D(chunk(entries, 7, moment.utc()), "MMM D Y");
    break;
  case "30d":
    data = boxplot7D(chunk(entries, 30, moment.utc()), "MMM D Y");
    break;
  }

  Plotly.newPlot('boxplotChart', data, layout);
}

function getType() {
  const menu = document.getElementById("graph_type");
  return menu.options[menu.selectedIndex].value;
}
