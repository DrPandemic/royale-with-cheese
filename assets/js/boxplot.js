import moment from "moment-mini";
const defaultFormat = {
  type: "box",
  jitter: 0.3,
  pointpos: -1.5,
  showlegend: false,
};
const defaultMarker = {
  // color: "rgb(212, 0, 0)",
  color: "rgb(20, 69, 135)",
};
const lineFormat = {
  line: {
    color: "rgb(72, 64, 93)",
    width: 1.5
  },
  mode: "lines",
  name: "median",
  showlegend: false,
  hoverinfo: "none",
};

export function boxplot7D(entries, format, unit) {
  if (entries.every(e => e.length === 0)) {
    return [];
  }

  const [data, dates] = extractPrice(entries);

  if (dates.length === 0) {
    return [];
  }

  const fullDates = fillDates(dates, unit);
  const sortedData = data.map(removeOutliers);
  const boxplots = sortedData.map((val, i) => createSingleBoxplot(val, i, fullDates, format));
  const line = createLine(sortedData, fullDates, format);

  return [...boxplots, line];
}

function extractPrice(entries) {
  const data = [];
  const dates = [];
  for (const i in entries) {
    if (!data[i]) {
      data[i] = [];
      dates[i] = undefined;
    }
    for (const entry of entries[i]) {
      if (entry.buyout === 0) {
        continue;
      }
      dates[i] = moment.utc(entry.dump_timestamp);
      data[i].push(entry.buyout / entry.quantity / 10000);
    }
  }
  return [data, dates];
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

function createSingleBoxplot(val, i, dates, format) {
  if (val.length === 0) {
    return {
      y: [0],
      name: dates[i].format(format),
      boxpoints: showSingleValues() ? "all" : false,
      line: {
        width: 0.2
      },
      marker: {
        ...defaultMarker,
        color: "rgb(58,131,206)",
      },
      ...defaultFormat,
    };
  }
  return {
    y: val,
    name: dates[i].format(format),
    boxpoints: showSingleValues() ? "all" : false,
    line: {
      width: 0.5
    },
    marker: {
      ...defaultMarker
    },
    ...defaultFormat
  };
}

function createLine(data, dates, format) {
  return {
    x: dates.map(d => d.format(format)),
    y: data.map(v => v[Math.floor(v.length / 2)]),
    ...lineFormat,
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

export const layout = {
  title: "Median price",
  yaxis: {
    title: "Price in gold per unit",
  },
}

function outlierSuppressionEnabled() {
  return document.getElementById("outlier-suppression").checked;
}

function showSingleValues() {
  return document.getElementById("show-singles").checked;
}
