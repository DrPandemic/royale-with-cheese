require("babel-polyfill");
import {preselectForm, fillSearchRecommendation} from './topBar';
import {displayGraph} from './graph';

preselectForm();

document.getElementById("item-name").addEventListener('input', fillSearchRecommendation);
document.getElementById("item-name").addEventListener('click', fillSearchRecommendation);

displayGraph();
document.getElementById("graph-duration").addEventListener('change', async () => { await displayGraph(); });
