import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payrolls-calculations"
export default class extends Controller {
  static targets = [
    "employeeSelect",
    "pay_date",
    "period_start",
    "period_end",
    "paymentMethod",
    "regular_hours",
    "vacation_hours",
    "sick_hours",
    "overtime_hours",
    "hourlyRate",
    "fixedSalary",
    "tips",
    "commissions",
    "bonuses",
    "other_payments_subject_to_contribution",
    "other_payments_subject_to_contribution_2",
    "expense_reimbursement",
    "allowances",
    "other_payments_not_subject_to_retention",
    "total_salaries",
    "gross_pay",
    "income_tax",
    "social_security_medicare",
    "medicare",
    "sinot",
    "medical_plan",
    "driver_weeks_worked",
    "driver_insurance",
    "asume",
    "donations",
    "other_deductions_1",
    "other_deductions_2",
    "other_deductions_3",
    "total_deductions",
    "net_pay",
    "sectionContainer", // Para mostrar/ocultar secciones
    "driver_checkbox",
    "driver_fields", // Para mostrar/ocultar campos de conductor
    "totalHours",
    "totalSpecialPayments",
    "totalSalary",
    "totalOtherPayments",
    "totalTaxesAndSecurity",
    "totalOtherDeductions",
    "totalOtherPaymentsNotSubjectToContribution"

  ];
  connect() {
    console.log("Payrolls conected");
    this.showFields();
  }

  updateValues(event) {
    const eventName = event.target.name;

    // controlls to change salary only when I change the employeeher
    if (eventName === "payroll[employee_id]") {
      this.showFields();
      this.updateHourlyRate();
      this.updateFixedSalary();
    }



    this.totalSalary(); // Agregar cálculo de total_salaries
    this.grossPay();
    this.socialSecurityMedicare();
    this.medicare();
    this.sinot();
    this.driverInsurance();
    this.totalDeductions();
    this.netPay();

  }

  updateHourlyRate() {
    const employees = JSON.parse(this.employeeSelectTarget.dataset.employees); // Obtiene datos de empleados
    const selectedEmployeeId = this.employeeSelectTarget.value;

    if (!selectedEmployeeId) {
      this.hourlyRateTarget.value = ""; // Limpia el campo si no hay empleado seleccionado
      return;
    }

    const employee = employees.find(emp => emp.id === parseInt(selectedEmployeeId));
    this.hourlyRateTarget.value = employee ? employee.hourly_rate : 0; // Actualiza el valor
  }

  updateFixedSalary() {
    const employees = JSON.parse(this.employeeSelectTarget.dataset.employees); // Obtiene datos de empleados
    const selectedEmployeeId = this.employeeSelectTarget.value;

    if (!selectedEmployeeId) {
      this.hourlyRateTarget.value = ""; // Limpia el campo si no hay empleado seleccionado
      return;
    }

    const employee = employees.find(emp => emp.id === parseInt(selectedEmployeeId));
    this.fixedSalaryTarget.value = employee ? employee.fixed_salary : 0; // Actualiza el valor
  }

  totalSalary() {
    const regular_hours = parseFloat(this.regular_hoursTarget.value) || 0;
    const vacation_hours = parseFloat(this.vacation_hoursTarget.value) || 0;
    const sick_hours = parseFloat(this.sick_hoursTarget.value) || 0;
    const overtime_hours = parseFloat(this.overtime_hoursTarget.value) || 0;
    const hourlyRate = parseFloat(this.hourlyRateTarget.value) || 0;

    // to update total hours field
    this.totalHoursTarget.innerText = `${regular_hours + vacation_hours + sick_hours + overtime_hours}`;

    const total_salaries =
      (regular_hours * hourlyRate) +
      (overtime_hours * hourlyRate * 1.5) +
      (vacation_hours * hourlyRate) +
      (sick_hours * hourlyRate);

    this.total_salariesTarget.value = total_salaries.toFixed(2); // Redondear a 2 decimales
  }


  grossPay() {
    // Casilla 23
    const total_salaries = parseFloat(this.total_salariesTarget.value) || 0;

    // Casillas 2 al 7
    // const hourly_rate = parseFloat(this.hourlyRateTarget.value) || 0;
    const fixed_salary = parseFloat(this.fixedSalaryTarget.value) || 0;
    const tips = parseFloat(this.tipsTarget.value) || 0;
    const commissions = parseFloat(this.commissionsTarget.value) || 0;
    const bonuses = parseFloat(this.bonusesTarget.value) || 0;
    const other_payments_subject_to_contribution = parseFloat(this.other_payments_subject_to_contributionTarget.value) || 0;
    const other_payments_subject_to_contribution_2 = parseFloat(this.other_payments_subject_to_contribution_2Target.value) || 0;
    const expense_reimbursement = parseFloat(this.expense_reimbursementTarget.value) || 0;
    const allowances = parseFloat(this.allowancesTarget.value) || 0;
    const other_payments_not_subject_to_retention = parseFloat(this.other_payments_not_subject_to_retentionTarget.value) || 0;

    // Total salary
    this.totalSalaryTarget.innerText = total_salaries + fixed_salary; // Redondear a 2 decimales

    // Special paymentes
    this.totalSpecialPaymentsTarget.innerText = `${tips + commissions + bonuses}`;

    // Other payments subject to contribution
    this.totalOtherPaymentsTarget.innerText = ` ${other_payments_subject_to_contribution
        + other_payments_subject_to_contribution_2}`;
    this.totalOtherPaymentsNotSubjectToContributionTarget.innerText =`${+expense_reimbursement+
      +allowances
      +other_payments_not_subject_to_retention}`;
    // Cálculo de grossPay
    const gross_pay =
      total_salaries +
      fixed_salary +
      tips +
      commissions +
      bonuses +
      other_payments_subject_to_contribution +
      other_payments_subject_to_contribution_2 +
      expense_reimbursement +
      allowances +
      other_payments_not_subject_to_retention;

    this.gross_payTarget.value = gross_pay.toFixed(2); // Redondear a 2 decimales
  }


  socialSecurityMedicare() {
    const baseAmount = this.baseAmount();
    // Multiplicar por 6.20%
    const social_security_medicare = baseAmount * 0.0620;

    // Actualizar el campo
    this.social_security_medicareTarget.value = social_security_medicare.toFixed(2); // Redondear a 2 decimales
  }


  medicare() {
    const baseAmount = this.baseAmount();
    // Multiplicar por 1.45%
    const medicare = baseAmount * 0.0145;

    // Actualizar el campo
    this.medicareTarget.value = medicare.toFixed(2); // Redondear a 2 decimales
  }


  sinot() {
    // Recuperar el año de pay_date
    const payDate = this.pay_dateTarget.value;
    const payYear = payDate ? new Date(payDate).getFullYear() : null;

    if (!payYear) {
      this.sinotTarget.value = 0; // Si no hay fecha válida, no calcular SINOT
      return;
    }

    if (this.driver_checkboxTarget.checked) {
      this.sinotTarget.value = 0;
      return;
    }

    // Recuperar datos del empleado seleccionado
    const employees = JSON.parse(this.employeeSelectTarget.dataset.employees);
    const sinotAcumulado = JSON.parse(this.employeeSelectTarget.dataset.sinotAcumulado);
    const selectedEmployeeId = parseInt(this.employeeSelectTarget.value);

    // Buscar el acumulado de salarios del empleado para el año de pay_date
    const employeeSinotAcum = sinotAcumulado.find(entry =>
      entry.employee_id === selectedEmployeeId && entry.year === payYear
    );
    const salaryAcum = employeeSinotAcum ? parseFloat(employeeSinotAcum.amount) : 0;
    const sinotAcum = employeeSinotAcum ? parseFloat(employeeSinotAcum.sinotAcum) : 0;

    // Límite de SINOT de salarios acumulados
    const salaryLimit = 9000.00;

    // Calcular el valor base de SINOT
    const total_salaries = parseFloat(this.total_salariesTarget.value) || 0; // Casilla 23
    const fixed_salary = parseFloat(this.fixedSalaryTarget.value) || 0;
    const other_payments_subject_to_contribution = parseFloat(this.other_payments_subject_to_contributionTarget.value) || 0; // Casilla 6
    const other_payments_subject_to_contribution_2 = parseFloat(this.other_payments_subject_to_contribution_2Target.value) || 0;

    const baseAmount = total_salaries + fixed_salary + other_payments_subject_to_contribution + other_payments_subject_to_contribution_2;

    // 6. Figure out how much of the base amount still falls under the limit
    //    i.e. the portion that has not yet reached $9,000.
    //    If `salaryAcum` = 8,500, there's $500 "room" left before reaching 9,000.
    let remainingPortion = salaryLimit - salaryAcum;   // e.g. 9000 - 8500 = 500
    if (remainingPortion < 0) remainingPortion = 0;    // Just in case

    // 7. Compare the baseAmount to the remaining portion
    //    - If our current payroll `baseAmount` is within that remaining portion,
    //      then we apply 3% to the entire baseAmount.
    //    - Otherwise, we only apply 3% to the portion that fits under the 9,000 limit.
    let sinotValue = 0;
    if (baseAmount <= remainingPortion) {
      // Entire baseAmount is below the limit
      sinotValue = baseAmount * 0.003;
    } else {
      // Part of baseAmount exceeds the limit
      sinotValue = remainingPortion * 0.003;
    }

    // 8. Assign the final SINOT value, rounded to 2 decimals
    this.sinotTarget.value = sinotValue.toFixed(2);




  }


  driverInsurance() {
    // Recuperar el valor de driver_weeks_worked (casilla 15)
    const driver_weeks_worked = parseFloat(this.driver_weeks_workedTarget.value) || 0;

    // Calcular el seguro del conductor
    const driver_insurance = driver_weeks_worked * 0.50;

    // Actualizar el campo driver_insurance
    this.driver_insuranceTarget.value = driver_insurance.toFixed(2); // Redondear a 2 decimales
  }


  totalDeductions() {
    // Recuperar valores de todas las deducciones
    const income_tax = parseFloat(this.income_taxTarget.value) || 0; // Casilla 9
    const social_security_medicare = parseFloat(this.social_security_medicareTarget.value) || 0; // Casilla 10
    const medicare = parseFloat(this.medicareTarget.value) || 0; // Casilla 11
    const sinot = parseFloat(this.sinotTarget.value) || 0; // Casilla 14
    const medical_plan = parseFloat(this.medical_planTarget.value) || 0; // Casilla 18
    const driver_insurance = parseFloat(this.driver_insuranceTarget.value) || 0; // Casilla 16
    const asume = parseFloat(this.asumeTarget.value) || 0; // Casilla 17
    const donations = parseFloat(this.donationsTarget.value) || 0; // Casilla 19
    const other_deductions_1 = parseFloat(this.other_deductions_1Target.value) || 0; // Casilla 20
    const other_deductions_2 = parseFloat(this.other_deductions_2Target.value) || 0; // Casilla 20
    const other_deductions_3 = parseFloat(this.other_deductions_3Target.value) || 0; // Casilla 20

    // update total taxes and security

    this.totalTaxesAndSecurityTarget.innerText = `${(income_tax
      + social_security_medicare
      + medicare + sinot
      + medical_plan).toFixed(2)}`;

    // update total other deductions
    this.totalOtherDeductionsTarget.innerText = `${(driver_insurance
      + asume
      + donations
      + other_deductions_1
      + other_deductions_2
      + other_deductions_3).toFixed(2)}`;
    // Sumar todas las deducciones
    const total_deductions =
      income_tax +
      social_security_medicare +
      medicare +
      sinot +
      driver_insurance +
      medical_plan +
      asume +
      donations +
      other_deductions_1 +
      other_deductions_2 +
      other_deductions_3;

    // Actualizar el campo total_deductions
    this.total_deductionsTarget.value = total_deductions.toFixed(2); // Redondear a 2 decimales
  }


  netPay() {
    // Recuperar los valores de gross_pay y total_deductions
    const gross_pay = parseFloat(this.gross_payTarget.value) || 0; // Casilla 8
    const total_deductions = parseFloat(this.total_deductionsTarget.value) || 0; // Casilla 21

    // Calcular el pago neto
    const net_pay = gross_pay - total_deductions;

    // Actualizar el campo net_pay
    this.net_payTarget.value = net_pay.toFixed(2); // Redondear a 2 decimales
  }


  showFields() {
    // Verify that all field values are filled

    const employeeSelect = this.employeeSelectTarget.value;
    const paymentMethod = this.paymentMethodTarget.value;
    const periodStart = this.period_startTarget.value;
    const periodEnd = this.period_endTarget.value;
    const payDate = this.pay_dateTarget.value;

    if (employeeSelect && paymentMethod && periodStart && periodEnd && payDate) {
      console.log("All fields are filled");

      this.sectionContainerTargets.forEach(togglableElement => {
        togglableElement.classList.remove("d-none");
      });
    } else {
      console.log(`Not all fields are filled:
        Employee Select: ${employeeSelect}
        Payment Method: ${paymentMethod}
        Period Start: ${periodStart}
        Period End: ${periodEnd}
        Pay Date: ${payDate}`);
      this.sectionContainerTargets.forEach(togglableElement => {
        togglableElement.classList.add("d-none");
      });
    }
  }

  togglechoferil(event){
    if (this.driver_checkboxTarget.checked) {
      this.driver_fieldsTarget.classList.remove("d-none")
      this.sinotTarget.value = 0;
    } else {
      this.driver_fieldsTarget.classList.add("d-none");
      this.driver_weeks_workedTarget.value = 0;
      this.driver_insuranceTarget.value = 0;
      this.updateValues(event);
    }
  }

  baseAmount() {
    const total_salaries = parseFloat(this.total_salariesTarget.value) || 0; // Casilla 23
    const fixed_salary = parseFloat(this.fixedSalaryTarget.value) || 0;        // Casilla 2
    const tips = parseFloat(this.tipsTarget.value) || 0;                    // Casilla 3
    const commissions = parseFloat(this.commissionsTarget.value) || 0;      // Casilla 4
    const bonuses = parseFloat(this.bonusesTarget.value) || 0;              // Casilla 5
    const other_payments_subject_to_contribution = parseFloat(this.other_payments_subject_to_contributionTarget.value) || 0; // Casilla 6
    const other_payments_subject_to_contribution_2 = parseFloat(this.other_payments_subject_to_contribution_2Target.value) || 0;


    // Sumar los valores de las casillas
    const baseAmount =
            total_salaries +
            fixed_salary +
            tips +
            commissions +
            bonuses +
            other_payments_subject_to_contribution+
            other_payments_subject_to_contribution_2;
    return baseAmount;

  }
}
