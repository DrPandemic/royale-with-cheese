import {preselectForm, fillSearchRecommendation, fillRealm, registerArrows} from "./topBar";
import {register} from "./webComponents";
import {redirectToIndex} from "./graph";
import {WowItem} from "./wowItem";

preselectForm();
registerArrows();

document.getElementById("item-name").addEventListener("input", fillSearchRecommendation);
document.getElementById("item-name").addEventListener("click", fillSearchRecommendation);
document.getElementById("region").addEventListener("change", fillRealm);

register();

fetchExpensive().then(d => showItems(d, "expensive"));
fetchPresent().then(d => showItems(d, "present"));

function fetchExpensive() {
  return fetch("/api/home/expensive").then(r => r.json()).catch(redirectToIndex);
}
function fetchPresent() {
  return fetch("/api/home/present").then(r => r.json()).catch(redirectToIndex);
}

function showItems(items, key) {
  const span = document.getElementById(key);
  items.forEach(item => {
    span.appendChild(new WowItem(item, `It was sold <b>${item.count}</b> times at an median price of <gold-price value='${item.price}' text='false' />.`));
  });
  document.getElementById(`loading-${key}`).classList.add("display-none");
}
