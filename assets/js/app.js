import css from "../css/app.css";
import "phoenix_html";

import {preselectForm} from './topBar';
import {displayGraph} from './graph';

preselectForm();
displayGraph();

document.getElementById("graph_type").addEventListener('change', displayGraph);
