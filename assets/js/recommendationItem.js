import {gotoItem} from "./topBar";

const template = document.createElement("template");
template.innerHTML = `
<div class="row" id="row">
  <div class="item">
    <img class="icon" id="icon"/>
    <p class="name" id="name"></p>
  </div>
</div>
`;

const style = document.createElement("style");
style.textContent = `.item {
  width: 100%;
  cursor: pointer;
  display: flex;
  align-items: center;
}
.name {
  overflow: hidden;
  margin-bottom: 0;
}
.row {
  border-bottom: 1px solid rgba(255, 255, 255, 0.7);
  padding: 5px 0 5px 5px;
}
.row.selected {
  background: white;
  font-weight: bold;
}
`;

class RecommendationItem extends HTMLElement {
  constructor() {
    super();
    this.icon = "";
    this.name = "";
    this.gotoItem = this.gotoItem.bind(this);
    this.select = this.select.bind(this);
    this.unselect = this.unselect.bind(this);
    this.selected = this.selected.bind(this);
  }

  connectedCallback() {
    this.icon = this.getAttribute("icon") || this.icon;
    this.name = this.getAttribute("name") || this.name;

    if (!this.shadowRoot) {
      this.attachShadow({mode: 'open'});
      this.shadowRoot.appendChild(style.cloneNode(true));
      this.shadowRoot.appendChild(template.content.cloneNode(true));
      this.shadowIcon = this.shadowRoot.getElementById("icon")
      this.shadowName = this.shadowRoot.getElementById("name")
      this.shadowRow = this.shadowRoot.getElementById("row")
      this.shadowRoot.addEventListener("click", this.gotoItem);
    }

    this.shadowIcon.src = this.icon;
    this.shadowName.innerText = this.name;
    this.shadowName.dataset.itemName = this.name;
  }

  disconnectedCallback() {
    this.shadowRoot.removeEventListener("click", this.gotoItem);
  }

  gotoItem() {
    gotoItem(this.name)
  }

  select() {
    this.shadowRow.classList.add("selected");
  }

  unselect() {
    this.shadowRow.classList.remove("selected");
  }

  selected() {
    return this.shadowRow.classList.contains("selected");
  }
}

export function register() {
  customElements.define("recommendation-item", RecommendationItem);
}
