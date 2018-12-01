require("babel-polyfill");
import css from "../css/app.css";
import "phoenix_html";

import {preselectForm, fillSearchRecommendation} from './topBar';
import {displayGraph} from './graph';

preselectForm();
displayGraph();

document.getElementById("item-name").addEventListener('input', fillSearchRecommendation);
document.getElementById("item-name").addEventListener('click', fillSearchRecommendation);
document.getElementById("graph-duration").addEventListener('change', async () => { await displayGraph(); });
