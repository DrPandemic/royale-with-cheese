import moment from 'moment';

export function chunk(data, days, startDate) {
  if (days > 1) {
    return chunkDays(data.data, days, startDate);
  } else {
    return chunkDay(data.data, startDate);
  }
}

function chunkDays(entries, days, startDate) {
  const init = [];
  for (let i = 0; i < days; ++i) {
    init.push([]);
  }

  entries.forEach(entry => {
    const timestamp = moment.utc(entry.dump_timestamp);
    const position = Math.round(startDate.diff(timestamp, 'hours') / 24);
    console.log(position);
    init[days - position - 1].push(entry);
  })


  return init;
}

function chunkDay(entries, startDate) {

}
