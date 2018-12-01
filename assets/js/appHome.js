require("babel-polyfill");
import {preselectForm, fillSearchRecommendation} from './topBar';

preselectForm();

document.getElementById("item-name").addEventListener('input', fillSearchRecommendation);
document.getElementById("item-name").addEventListener('click', fillSearchRecommendation);
