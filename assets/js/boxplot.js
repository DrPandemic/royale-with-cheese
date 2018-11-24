import moment from 'moment';
const outlierTreshold = 0.5;

export function boxplot7D(entries) {
  let data = [];
  for (const i in entries) {
    if (!data[i]) {
      data[i] = [];
    }
    for (const entry of entries[i]) {
      if (entry.buyout === 0) {
        continue;
      }
      data[i].push(entry.buyout / entry.quantity / 10000);
    }
  }

  return data.map(val => {
    const dataNoOutiliers = removeOutliers(val);
    // Prevent the outlier detection to remove everything. This is an issue the que pet cage
    if (dataNoOutiliers.length > val.length * outlierTreshold) {
      return dataNoOutiliers;
    }
    return val;
  }).map((val, i) => {
    if (val.length === 0) {
      return null;
    }
    return {
      y: val,
      name: moment.utc(entries[i][0].dump_timestamp).format("MMM D Y"),
      boxpoints: 'all',
      jitter: 0.3,
      pointpos: -1.5,
      type: 'box',
      line: {
        width: 0.5
      },
      marker: {
        color: 'rgb(8,81,156)',
        outliercolor: 'rgba(215, 40, 40, 0.1)',
        line: {
          outliercolor: 'rgba(215, 40, 40, 0.1)',
          outlierwidth: 20
        }
      }
    };
  }).filter(d => d);
}

function removeOutliers(data) {
  if (data.length === 0) {
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
  yaxis: {
    title: 'Price in gold per unit',
  },
}
