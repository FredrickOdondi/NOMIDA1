import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";
// Connects to data-controller="datepicker"
export default class extends Controller {

  connect() {
    // Configure specific inputs
    flatpickr(this.element);
  }

  

}
