const name = "world";

foo.innerHTML = `
  <div>
    Hello ${name}!
  </div>
`;

bar.innerHTML = `<div>${name}</div>`;

// Ensure nested braces within the interpolation don't break placeholder matching.
baz.innerHTML = `
  <div>
    ${fn({ a: 1, b: { c: 2 } })}
  </div>
`;
