import {register as recommendationRegister} from "./recommendationItem";
import {register as itemRegister} from "./wowItem";
import {register as priceRegister} from "./goldPrice";

export function register() {
  recommendationRegister();
  itemRegister();
  priceRegister();
}
