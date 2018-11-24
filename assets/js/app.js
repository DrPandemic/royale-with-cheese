import css from "../css/app.css";
import "phoenix_html";

import Plotly from 'plotly.js-dist';
import moment from 'moment';
import {chunk} from './chunk';
import {boxplot7D, layout} from "./boxplot";
import {preselectForm} from './topBar';

preselectForm();

const entries = JSON.parse(document.getElementById('boxplotChart').dataset['entries']);
const data = boxplot7D(chunk(entries, 7, moment.utc()));
Plotly.newPlot('boxplotChart', data, layout);
