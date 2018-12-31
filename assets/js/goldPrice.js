const template = document.createElement("template");
template.innerHTML = `
<div class="container">
  <span id="gold" class="gold"></span>
  <span id="silver" class="silver"></span>
  <span id="copper" class="copper"></span>
</div>
`;

const style = document.createElement("style");
style.textContent = `
.gold {
  background: no-repeat right center;
  background-image: url('/images/blizzard/icons/money-gold.gif');
  padding-right: 15px;
}
.silver {
  background: no-repeat right center;
  background-image: url('/images/blizzard/icons/money-silver.gif');
  padding-right: 15px;
}
.copper {
  background: no-repeat right center;
  background-image: url('/images/blizzard/icons/money-copper.gif');
  padding-right: 15px;
}
`;

class GoldPrice extends HTMLElement {
  constructor() {
    super();
    this.value = 0;
    this.render = this.render.bind(this);
  }

  connectedCallback() {
    this.value = this.getAttribute("value") || this.value;

    if (!this.shadowRoot) {
      this.attachShadow({mode: 'open'});
      this.shadowRoot.appendChild(style.cloneNode(true));
      this.shadowRoot.appendChild(template.content.cloneNode(true));
    }
    this.render();
  }

  render() {
    if (this.shadowRoot) {
      this.shadowRoot.getElementById("gold").innerText = Math.floor(this.value / 10000);
      this.shadowRoot.getElementById("silver").innerText = Math.floor((this.value / 100) % 100);
      this.shadowRoot.getElementById("copper").innerText = Math.floor((this.value) % 100);
    }
  }

  static get observedAttributes() { return ["value"]; }
  attributeChangedCallback(name, oldValue, newValue) {
    this.value = parseInt(newValue);
    this.render();
  }
}

export function register() {
  customElements.define("gold-price", GoldPrice);
}
