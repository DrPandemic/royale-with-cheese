const template = document.createElement("template");
template.innerHTML = `
<div class="container" id="container">
  Sell Price: 
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
.hidden {
  display: none;
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
      if (this.value == 0) {
        this.shadowRoot.getElementById("container").classList.add("hidden");
      } else {
        this.shadowRoot.getElementById("container").classList.remove("hidden");
        const gold = Math.floor(this.value / 10000);
        const silver = Math.floor((this.value / 100) % 100);
        if (gold <= 0) {
          this.shadowRoot.getElementById("gold").classList.add("hidden");
        } else {
          this.shadowRoot.getElementById("gold").innerText = gold;
        }
        if (gold <= 0 && silver <= 0) {
          this.shadowRoot.getElementById("silver").classList.add("hidden");
        } else {
          this.shadowRoot.getElementById("silver").innerText = silver;
        }
        this.shadowRoot.getElementById("copper").innerText = Math.floor((this.value) % 100);
      }
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
