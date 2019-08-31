describe("Draw", () => {
  beforeEach("", () => {
    cy.visit("/graph");
  });

  it("switches to Aboriginal Studies", () => {
    cy.get("#sidebar-button").click();
    cy.contains("Aboriginal").click();
    cy.get("#sidebar-button").click();
  });
});
