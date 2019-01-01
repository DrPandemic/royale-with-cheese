const template = document.createElement("template");
template.innerHTML = `
<span class="container" id="container">
  <span id="text">Sell Price: </span>
  <span id="gold" class="gold"></span>
  <span id="silver" class="silver"></span>
  <span id="copper" class="copper"></span>
</span>
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
    this.text = 'true';
    this.render = this.render.bind(this);
  }

  connectedCallback() {
    this.value = this.getAttribute("value") || this.value;
    this.text = this.getAttribute("text") || this.text;

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
        if (this.text == "false") {
          this.shadowRoot.getElementById("text").classList.add("hidden");
        } else {
          this.shadowRoot.getElementById("text").classList.remove("hidden");
        }
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

  static get observedAttributes() { return ["value", "text"]; }
  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "value") {
      this.value = parseInt(newValue);
    } else {
      this[name] = newValue;
    }
    this.render();
  }
}

export function register() {
  customElements.define("gold-price", GoldPrice);
}
