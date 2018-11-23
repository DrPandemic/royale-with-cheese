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
  }).map((val, i) => ({
    y: val,
    name: ((entries[i] || [])[0] || {dump_timestamp: ''}).dump_timestamp,
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
    },
  }));
}

function removeOutliers(data) {
  data.sort();

  const median = percentile(data, 50);
  const q1 = percentile(data, 25);
  const q3 = percentile(data, 75);
  const iqr = Math.max(q3 - q1, median / 10) * 1.5;

  return data.filter(e => e > q1 - iqr && e < q3 + iqr);
}

function percentile(list, n) {
  const r = n / 100 * list.length;
  const f = Math.ceil(r);
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
