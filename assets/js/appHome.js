import {preselectForm, fillSearchRecommendation, fillRealm, registerArrows} from "./topBar";
import {register as recommendationRegister} from "./recommendationItem";

preselectForm();
registerArrows();

document.getElementById("item-name").addEventListener("input", fillSearchRecommendation);
document.getElementById("item-name").addEventListener("click", fillSearchRecommendation);
document.getElementById("region").addEventListener("change", fillRealm);

recommendationRegister();
