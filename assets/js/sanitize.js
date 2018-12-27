import moment from 'moment-mini';

export function chunk(data, days, endDate) {
  if (days > 1) {
    return chunkPartition(data.data, days, endDate, (a, b) => Math.round(a.diff(b.startOf("day"), 'hours') / 24));
  } else {
    return chunkPartition(data.data, 24, endDate, (a, b) => Math.round(a.diff(b, 'minutes') / 60));
  }
}

function chunkPartition(entries, steps, endDate, diff) {
  const init = [];
  for (let i = 0; i < steps; ++i) {
    init.push([]);
  }

  entries.forEach(entry => {
    const timestamp = moment.utc(entry.dump_timestamp);
    const position = diff(endDate, timestamp);
    if (position >= 0 && position < steps) {
      init[steps - position - 1].push(entry);
    }
  });

  return init;
}
