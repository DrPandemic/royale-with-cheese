import {register as recommendationRegister} from "./recommendationItem";
import {register as itemRegister} from "./wowItem";

export function register() {
  recommendationRegister();
  itemRegister()
}
