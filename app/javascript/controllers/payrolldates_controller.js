import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";
// Connects to data-controller="payrolldates"
export default class extends Controller {
  static targets = [ "periodStart", "periodEnd", "payDate", "generalDatepicker" ];

  connect() {
    // Configure specific inputs
    if (this.hasPeriodStartTarget) {
      flatpickr(this.periodStartTarget, {
        onChange: this.updatePeriodEndMinDate.bind(this),
      });
    }

    if (this.hasPeriodEndTarget) {
      flatpickr(this.periodEndTarget, {
        minDate: this.getPeriodStartValue(),
      });
    }

    if (this.hasPayDateTarget) {
      flatpickr(this.payDateTarget, {
        minDate: this.getPeriodStartValue(),
      });
    }

    this.generalDatepickerTargets.forEach((element) => {
      if (!(element === this.periodStartTarget ||
        element === this.periodEndTarget)) {
        flatpickr(element);
      }
    });
  }

  initPeriodStartPicker() {

    flatpickr(this.element, {
      onChange: this.updatePeriodEndMinDate.bind(this)
    });
  }

  initPeriodEndPicker() {
    flatpickr(this.element, {
      minDate: this.getPeriodStartValue(),
    });
  }

  updatePeriodEndMinDate(selectedDates) {
    const periodEndElement = this.periodEndTarget;
    if (periodEndElement) {
      const periodEndPicker = flatpickr(periodEndElement);
      periodEndPicker.set("minDate", selectedDates[0]);
      periodEndPicker.set("disable",[(date) => date <  selectedDates[0]]);
    }

    const payDateElement = this.payDateTarget;
    if (payDateElement) {
      const payDatePicker = flatpickr(payDateElement);
      payDatePicker.set("minDate", selectedDates[0]);
    }
  }

  getPeriodStartValue() {
    return this.periodStartTarget.value || null;
  }
}
