const name = "world";

// Interpolation split across lines should still be preserved.
foo.innerHTML = `
  <div>
    Hello ${name
	}!
  </div>
`;
