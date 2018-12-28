import moment from 'moment-mini';
const outlierTreshold = 0.5;
const defaultFormat = {
  type: 'box',
  jitter: 0.3,
  pointpos: -1.5,
};
const defaultMarker = {
  color: 'rgb(8,81,156)',
};

export function boxplot7D(entries, format) {
  let data = [];
  let dates = [];
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

  if (dates.length === 0) {
    return [];
  }

  fillDates(dates);

  return data.map(val => {
    const dataNoOutiliers = removeOutliers(val);
    // Prevent the outlier detection from removing everything. This is an issue with the pet cage
    if (dataNoOutiliers.length > val.length * outlierTreshold) {
      return dataNoOutiliers;
    }
    return val;
  }).map((val, i) => {
    if (val.length === 0) {
      return {
        y: [0],
        name: dates[i].format(format),
        boxpoints: showSingleValues() ? 'all' : false,
        line: {
          width: 0.2
        },
        marker: {
          ...defaultMarker,
          color: 'rgb(58,131,206)',
        },
        ...defaultFormat,
      };
    }
    return {
      y: val,
      name: dates[i].format(format),
      boxpoints: showSingleValues() ? 'all' : false,
      line: {
        width: 0.5
      },
      marker: {
        ...defaultMarker
      },
      ...defaultFormat
    };
  });
}

function fillDates(dates) {
  let max = dates.length;
  while (dates.includes(undefined) && --max > 0) {
    for (let i in dates) {
      const j = parseInt(i);
      if (j > 0 && !dates[j - 1] && dates[j]) {
        dates[j - 1] = dates[j].clone().add(-1, 'days');
      }
      if (j < dates.length - 1 && !dates[j + 1] && dates[j]) {
        dates[j + 1] = dates[j].clone().add(1, 'days');
      }
    }
  }
}

function removeOutliers(data) {
  if (data.length === 0 || !outlierSuppressionEnabled()) {
    return data;
  }
  data.sort((a, b) => a - b);

  const median = percentile(data, 50);
  const q1 = percentile(data, 25);
  const q3 = percentile(data, 75);
  const iqr = (q3 - q1) * 1.5;

  return data.filter(e => e > q1 - iqr && e < q3 + iqr);
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
  title: 'Median price',
  yaxis: {
    title: 'Price in gold per unit',
  },
}

function outlierSuppressionEnabled() {
  return document.getElementById('outlier-suppression').checked;
}

function showSingleValues() {
  return document.getElementById('show-singles').checked;
}
