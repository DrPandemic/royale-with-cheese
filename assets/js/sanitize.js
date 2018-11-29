import moment from 'moment';

export function chunk(data, days, startDate) {
  if (days > 1) {
    return chunkPartition(data.data, days, startDate, (a, b) => Math.round(a.diff(b.startOf("day"), 'hours') / 24));
  } else {
    return chunkPartition(data.data, 24, startDate, (a, b) => Math.round(a.diff(b.startOf("day"), 'minutes') / 60));
  }
}

function chunkPartition(entries, steps, startDate, diff) {
  const init = [];
  for (let i = 0; i < steps; ++i) {
    init.push([]);
  }

  entries.forEach(entry => {
    const timestamp = moment.utc(entry.dump_timestamp);
    const position = diff(startDate, timestamp);
    if (position >= 0 && position < steps) {
      init[steps - position - 1].push(entry);
    }
  });

  return init;
}
