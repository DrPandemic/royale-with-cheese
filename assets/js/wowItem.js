import {gotoItem} from "./topBar";

const template = document.createElement("template");
template.innerHTML = `
<div class="container">
  <span class="inner-container">
    <span id="item" class="item">
      <img id="icon"/>
      <span id="name" class="name"></span>
    </span>
  </span>
  <div id="tooltip" class="tooltip">
    <div id="t-name" class="t-name">foo</div>
    <div id="t-item-level" class="t-item-level"></div>
    <div id="t-description" class="t-item-level"></div>
    <div id="t-requires-level"></div>
    <gold-price id="t-price" value="0"></gold-price>
  </div>
  <div id="text" class="text"></div>
</div>
`;

const style = document.createElement("style");
style.textContent = `
.container {
  margin: 0 0 15px 20px;
  position: relative;
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

.tooltip {
  max-width: 300px;
  top: -3px;
  left: 38px;
  background-color: #090d20;
  color: white;
  border-radius: 5px;
  position: absolute;
  opacity: 0;
  visibility: hidden;
  transition: visibility 0s linear 0.3s,opacity 0.3s linear;
  border-style: outset;
  border-width: 2px;
  padding: 5px 5px 0 5px;
  z-index: 5;
}
.inner-container:hover + .tooltip,
.tooltip:hover {
  opacity: 1;
  visibility: visible;
  transition-delay: 0s;
}
.t-item-level {
  color: #ffd100;
}
.quality-0 {
  color: #9d9d9d;
}
.quality-1 {
  color: #ffffff;
}
.quality-2 {
  color: #1eff00;
}
.quality-3 {
  color: #1eff00;
}
.quality-4 {
  color: #a335ee;
}
.quality-5 {
  color: #ff8000;
}
.quality-6 {
  color: #e6cc80;
}
.quality-7 {
  color: #00ccf;
}
.quality-8 {
  color: #00ccf;
}
`;

class WowItem extends HTMLElement {
  constructor() {
    super();
    this.item = {};
    this.text = "";
    this.gotoItem = this.gotoItem.bind(this);
    this.render = this.render.bind(this);
  }

  connectedCallback() {
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

    this.render();
  }

  render() {
    this.item = JSON.parse(this.getAttribute("item")) || this.icon;
    if (Object.keys(this.item).length === 0) {
      return;
    }
    this.text = this.getAttribute("text") || this.text;

    if (this.shadowRoot) {
      this.shadowIcon.src = `/images/blizzard/icons/36/${this.item.icon}.jpg`;
      this.shadowName.innerText = this.item.name;
      this.shadowText.innerHTML = this.text;

      this.shadowRoot.getElementById("t-name").classList.add(`quality-${this.item.quality}`);
      this.shadowRoot.getElementById("t-name").innerText = this.item.name;
      this.shadowRoot.getElementById("t-item-level").innerText = `Item Level ${this.item.item_level}`;
      if (this.item.description !== "") {
        this.shadowRoot.getElementById("t-description").innerText = `"${this.item.description}"`;
      }
      if (this.item.required_level > 0) {
        this.shadowRoot.getElementById("t-requires-level").innerText = `Requires level ${this.item.required_level}`;
      }
      this.shadowRoot.getElementById("t-price").setAttribute("value", this.item.sell_price);
    }
  }

  disconnectedCallback() {
    this.shadowItem.removeEventListener("click", this.gotoItem);
  }

  gotoItem() {
    gotoItem(this.item.name)
  }

  static get observedAttributes() { return ["item", "text"]; }
  attributeChangedCallback(name, oldValue, newValue) {
    this[name] = newValue;
    this.render();
  }
}

export function register() {
  customElements.define("wow-item", WowItem);
}
