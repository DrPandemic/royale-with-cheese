require("babel-polyfill");
import {preselectForm, fillSearchRecommendation, fillRealm} from './topBar';
import {displayGraph} from './graph';

preselectForm();

document.getElementById("item-name").addEventListener("input", fillSearchRecommendation);
document.getElementById("item-name").addEventListener("click", fillSearchRecommendation);
document.getElementById("region").addEventListener("change", fillRealm);

displayGraph();
document.getElementById("graph-duration").addEventListener("change", async () => { await displayGraph(); });
