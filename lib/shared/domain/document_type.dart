/// Category of a captured medical document.
enum DocumentType {
  labReport('Lab report'),
  prescription('Prescription'),
  dischargeSummary('Discharge summary'),
  bill('Bill'),
  handwrittenNote('Handwritten note'),
  scan('Scan');

  const DocumentType(this.label);

  final String label;
}
