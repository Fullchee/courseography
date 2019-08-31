describe("FCE Count Spec", () => {
  it("Selecting a course node should always increase the FCE count by 0.5, (currently no support for full-year courses)", () => {
    cy.get("[data-testId=aaa100]").click();
    cy.get("#fcecount").contains("FCE Count: 0.5");
    cy.get("[data-testId=aaa201]").click();
    cy.get("#fcecount").contains("FCE Count: 1");
    cy.get("[data-testId=aaa100]").click();
    cy.get("#fcecount").contains("FCE Count: 0.5");
    cy.get("[data-testId=aaa201]").click();
    cy.get("#fcecount").contains("FCE Count: 0");
  });
  it("will transfer the FCE count when switching between graphs", () => {
    // TODO: add from CS, then add from aboriginal studies
    // should add up to 1.0
  });

  // it("Full year courses will increase the FCE by 1.0", () => {});

  // TODO: Courses with FCE Prerequisites
  // https://github.com/Courseography/courseography/issues/344
  // it("CSC318 should only be 'takeable' with 1+ CSC half-course ", () => {});

  // it("CSC454 should only be 'takeable' with 5+ CSC half-courses at the 200+ level", () => {});
});
