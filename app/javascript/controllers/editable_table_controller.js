import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="editable-table"

export default class extends Controller {
  static targets = ["editable"];
  static values = { companyId: Number };

  connect() {
    console.log("Editable table controller connected");
    this.editableTargets.forEach((cell) => {
      cell.addEventListener("click", this.makeEditable.bind(this));
    });
  }

  makeEditable(event) {
    const cell = event.currentTarget;
    if (cell.querySelector("input")) return;

    const currentValue = cell.innerText;
    const input = document.createElement("input");

    input.type = "text";
    input.value = currentValue;
    input.className = "form-control";
    cell.innerHTML = "";
    cell.appendChild(input);
    input.focus();

    input.addEventListener("blur", () => {
      const newValue = input.value;
      cell.innerText = newValue;
      const companyId = this.companyIdValue // adjust to retrieve the company ID
      this.updatePayroll(companyId, cell.dataset.id, cell.dataset.field, newValue);
    });

    input.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        input.blur();
      }
    });
  }

  updatePayroll(companyId, payrollId, field, value)  {
    fetch(`/companies/${companyId}/payrolls/${payrollId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
      },
      body: JSON.stringify({
        payroll: {
          [field]: value,
        },
      }),
    }).then((response) => {
      if (!response.ok) {
        alert("Error al actualizar el valor.");
      }
    });
  }
}
