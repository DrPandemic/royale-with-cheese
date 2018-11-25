import moment from 'moment';

export function chunk(data, days, startDate) {
  if (days > 1) {
    return chunkDays(data.data, days, startDate, (a, b) => Math.round(a.diff(b, 'hours') / 24));
  } else {
    return chunkDays(data.data, 24, startDate, (a, b) => Math.round(a.diff(b, 'minutes') / 60));
  }
}

function chunkDays(entries, steps, startDate, diff) {
  const init = [];
  for (let i = 0; i < steps; ++i) {
    init.push([]);
  }

  entries.forEach(entry => {
    const timestamp = moment.utc(entry.dump_timestamp);
    const position = diff(startDate, timestamp);
    console.log(steps - position - 1, timestamp.format("D kk") + "h");
    if (position >= 0 && position < steps) {
      init[steps - position - 1].push(entry);
    }
  });

  return init;
}
