import {preselectForm, fillSearchRecommendation, fillRealm, registerArrows} from './topBar';
import {displayGraph, toggleAdvancedOptions, toggleOutlierSuppression, toggleShowSingles} from './graph';
import {register} from "./webComponents";

preselectForm();
registerArrows();

document.getElementById("item-name").addEventListener("input", fillSearchRecommendation);
document.getElementById("item-name").addEventListener("click", fillSearchRecommendation);
document.getElementById("region").addEventListener("change", fillRealm);

displayGraph();
document.getElementById("graph-duration").addEventListener("change", async () => { await displayGraph(); });

document.getElementById("advanced-option-toggle").addEventListener("click", toggleAdvancedOptions);
document.getElementById("outlier-suppression").addEventListener("change", async () => { await displayGraph(); });
document.getElementById("show-singles").addEventListener("change", async () => { await displayGraph(); });

register();
