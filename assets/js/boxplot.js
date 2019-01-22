import moment from "moment-mini";
const defaultFormat = {
  type: "box",
  jitter: 0.3,
  pointpos: -1,
};
const markerAlliance = {
  color: "rgb(20, 69, 135)",
};
const markerHorde = {
  color: "rgb(212, 0, 0)",
};

export const layout = {
  title: "Median price",
  yaxis: {
    title: "Price in gold per unit",
  },
  boxmode: "group",
}

export function boxplot7D(entries, format, unit) {
  if (entries.every(e => e.length === 0)) {
    return [];
  }

  const [alliance, horde, dates] = extractPrice(entries);

  if (dates.length === 0) {
    return [];
  }

  const fullDates = fillDates(dates, unit);
  const sortedHorde = fillData(horde.map(removeOutliers));
  const sortedAlliance = fillData(alliance.map(removeOutliers));
  const boxplotHorde = createSingleBoxplot(sortedHorde, fullDates, format, false);
  const boxplotAlliance = createSingleBoxplot(sortedAlliance, fullDates, format, true);

  return [boxplotHorde, boxplotAlliance];
}

function extractPrice(entries) {
  const horde = [];
  const alliance = [];
  const dates = [];
  for (const i in entries) {
    if (!horde[i]) {
      horde[i] = [];
      alliance[i] = [];
      dates[i] = undefined;
    }
    for (const entry of entries[i]) {
      if (entry.buyout === 0) {
        continue;
      }
      dates[i] = moment.utc(entry.dump_timestamp);
      if (entry.faction === 1) {
        horde[i].push(entry.buyout / entry.quantity / 10000);
      } else {
        alliance[i].push(entry.buyout / entry.quantity / 10000);
      }
    }
  }
  return [alliance, horde, dates];
}

function fillDates(dates, unit) {
  let max = dates.length;
  while (dates.includes(undefined) && --max > 0) {
    for (let i in dates) {
      const j = parseInt(i);
      if (j > 0 && !dates[j - 1] && dates[j]) {
        dates[j - 1] = dates[j].clone().add(-1, unit);
      }
      if (j < dates.length - 1 && !dates[j + 1] && dates[j]) {
        dates[j + 1] = dates[j].clone().add(1, unit);
      }
    }
  }
  return dates;
}

function fillData(data, dates) {
  return data.map(d => d.length === 0 ? [0] : d);
}

function removeOutliers(data) {
  data.sort((a, b) => a - b);

  if (data.length === 0 || !outlierSuppressionEnabled()) {
    return data;
  }

  const median = percentile(data, 50);
  const q1 = percentile(data, 25);
  const q3 = percentile(data, 75);
  const iqr = (q3 - q1) * 1.5;

  return data.filter(e => e <= q3 + iqr);
}

function createSingleBoxplot(sortedData, dates, format, alliance) {
  const marker = alliance ? markerAlliance : markerHorde;
  const name = alliance ? "Alliance" : "Horde";
  const x = sortedData.map((d, i) => d.map(_ => dates[i].format(format))).flat();
  return {
    y: sortedData.flat(),
    x,
    name: name,
    boxpoints: showSingleValues() ? "all" : false,
    line: {
      width: 0.5
    },
    marker: {
      ...marker,
    },
    ...defaultFormat
  };
}

function percentile(list, n) {
  const r = n / 100 * list.length;
  const f = Math.min(Math.max(Math.ceil(r), 0), list.length - 1);
  if (Math.floor(r) !== f) {
    return list[f];
  } else {
    const lower = list[f];
    const upper = list[f - 1];
    return (lower + upper) / 2
  }
}

function outlierSuppressionEnabled() {
  return document.getElementById("outlier-suppression").checked;
}

function showSingleValues() {
  return document.getElementById("show-singles").checked;
}
