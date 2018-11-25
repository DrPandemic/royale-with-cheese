require("babel-polyfill");
import css from "../css/app.css";
import "phoenix_html";

import {preselectForm} from './topBar';
import {displayGraph} from './graph';

preselectForm();
displayGraph();

document.getElementById("graph_duration").addEventListener('change', async () => { await displayGraph(); });
