import css from "../css/app.css"
import "phoenix_html"

import Plotly from 'plotly.js-dist';
import {boxplot7D, layout} from "./boxplot";
import {preselectForm} from './topBar';

preselectForm();

const entries = JSON.parse(document.getElementById('boxplotChart').dataset['entries']);
const data = boxplot7D(entries);
Plotly.newPlot('boxplotChart', data, layout);
