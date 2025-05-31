import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

export default class extends Controller {
  connect() {
    this.toast = new Toast(this.element, { delay: 5000 });
    this.toast.show();
  }
}
