import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="service-payment-calculations"
export default class extends Controller {

  static targets = [
    "amountA",
    "amountB",
    "amountC",
    "deductionPercentage",



    "paidToIndividualsNoRetention", // new fields start here
    "paidToCorporationNoRetention",
    "paidToIndividualsWithRetention",
    "retentionPercentageIndividuals",
    "retentionIndividuals", // to calculate
    "paidToCorporationWithRetention",
    "retentionPercentageCorporation",
    "retentionCorporation", // to calculate
    "reimbursedExpenses",
    "responsibilityPaymentHealthProviders",
    "specialContributionServices",
    "grossAmount", // to calculate
    "deductionAmount", // to calculate
    "netAmount" // to calculate

  ];


  connect() {
    console.log("ServicePaymentCalculations connected");
  }

  servicePaymentCalculations() {
    // Obtener valores de los campos
    const paidToIndividualsNoRetention = parseFloat(this.paidToIndividualsNoRetentionTarget.value) || 0;
    const paidToCorporationNoRetention = parseFloat(this.paidToCorporationNoRetentionTarget.value) || 0;
    const paidToIndividualsWithRetention = parseFloat(this.paidToIndividualsWithRetentionTarget.value) || 0;
    const retentionPercentageIndividuals = parseFloat(this.retentionPercentageIndividualsTarget.value) || 0;

    const paidToCorporationWithRetention = parseFloat(this.paidToCorporationWithRetentionTarget.value) || 0;
    const retentionPercentageCorporation = parseFloat(this.retentionPercentageCorporationTarget.value) || 0;

    const reimbursedExpenses = parseFloat(this.reimbursedExpensesTarget.value) || 0;
    const responsibilityPaymentHealthProviders = parseFloat(this.responsibilityPaymentHealthProvidersTarget.value) || 0;
    const specialContributionServices = parseFloat(this.specialContributionServicesTarget.value) || 0;

    this.retentionIndividualsTarget.value = (paidToIndividualsWithRetention * retentionPercentageIndividuals / 100).toFixed(2);
    this.retentionCorporationTarget.value = (paidToCorporationWithRetention * retentionPercentageCorporation / 100).toFixed(2);

    const retentionIndividuals = parseFloat(this.retentionIndividualsTarget.value) || 0;
    const retentionCorporation = parseFloat(this.retentionCorporationTarget.value) || 0;

    // Calcular el monto bruto
    const grossAmount = paidToIndividualsNoRetention + paidToCorporationNoRetention +
                        paidToIndividualsWithRetention + paidToCorporationWithRetention
                        + reimbursedExpenses + responsibilityPaymentHealthProviders  + specialContributionServices;

    this.grossAmountTarget.value = grossAmount.toFixed(2);

    // Calcular el monto de deducción
    const deductionAmount = retentionIndividuals +  retentionCorporation;
    this.deductionAmountTarget.value = deductionAmount.toFixed(2);

    // Calcular el monto neto
    const netAmount = grossAmount - deductionAmount;
    this.netAmountTarget.value = netAmount.toFixed(2);
  }
}
