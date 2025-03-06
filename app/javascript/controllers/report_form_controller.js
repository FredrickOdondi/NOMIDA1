import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report-form"
export default class extends Controller {
  static targets = ["reportType", "filterGroup"]

  connect() {
    console.log("Report form controller connected")
  }

  updateFilters(event) {
    console.log(this.reportTypeTarget.value);
    const reportType = this.reportTypeTarget.value;

    // Hide all filter groups
    this.filterGroupTargets.forEach(group => {
      group.style.display = "none";
    });

    // Show the filter group for the selected report type
    const selectedGroup = this.filterGroupTargets.find(group =>
      group.dataset.filterType === reportType
    );

    if (selectedGroup) {
      selectedGroup.style.display = "block";
      console.log("Selected group:", selectedGroup);
    }
  }
}
