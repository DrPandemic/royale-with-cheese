import {gotoItem} from "./topBar";

const template = document.createElement("template");
template.innerHTML = `
<div class="container">
  <span id="item" class="item">
    <img id="icon"/>
    <span id="name" class="name"></span>
  </span>
  <div id="text" class="text"></div>
</div>
`;

const style = document.createElement("style");
style.textContent = `
.container {
  margin: 0 0 15px 20px;
}
.item {
  cursor: pointer;
}
.name {
  font-size: 28px;
  font-weight: 300;
}
.text {
  color: #000000;
  font-family: 'Helvetica', 'Arial', sans-serif;
  font-size: 16px;
  font-weight: 300;
  line-height: 25.6px;
  letter-spacing: normal;
}
`;

export class WowItem extends HTMLElement {
  constructor() {
    super();
    this.icon = "";
    this.name = "";
    this.text = "";
    this.gotoItem = this.gotoItem.bind(this);
  }

  connectedCallback() {
    this.icon = this.getAttribute("icon") || this.icon;
    this.name = this.getAttribute("name") || this.name;
    this.text = this.getAttribute("text") || this.text;

    if (!this.shadowRoot) {
      this.attachShadow({mode: 'open'});
      this.shadowRoot.appendChild(style.cloneNode(true));
      this.shadowRoot.appendChild(template.content.cloneNode(true));
      this.shadowItem = this.shadowRoot.getElementById("item")
      this.shadowIcon = this.shadowRoot.getElementById("icon")
      this.shadowName = this.shadowRoot.getElementById("name")
      this.shadowText = this.shadowRoot.getElementById("text")
      this.shadowItem.addEventListener("click", this.gotoItem);
    }

    this.shadowIcon.src = this.icon;
    this.shadowName.innerText = this.name;
    this.shadowText.innerHTML = this.text;
  }

  disconnectedCallback() {
    this.shadowItem.removeEventListener("click", this.gotoItem);
  }

  gotoItem() {
    gotoItem(this.name)
  }
}

export function register() {
  customElements.define("wow-item", WowItem);
}
