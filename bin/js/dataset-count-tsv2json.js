#!/usr/bin/env node
const program = require('commander');
const fs = require('fs');

program
  .option('-v, --verbose', 'verbose')
  .arguments('[INPUT]')
  .parse(process.argv);

const opts = program.opts();

let input;
if (program.args[0]) {
  try {
    input = fs.readFileSync(program.args[0], "utf8");
  } catch (err) {
    console.error(`cannot open ${program.args[0]}`);
    process.exit(1);
  }
} else if (process.stdin.isTTY) {
  program.help();
  process.exit(1);
} else {
  try {
    input = fs.readFileSync(process.stdin.fd).toString();
  } catch (err) {
    process.exit(1);
  }
}
let lines = input.trim().split('\n');

let out = {};
lines.forEach((line) => {
  let dataset, count;
  [dataset, count] = line.split('\t');
  if (parseInt(count)) {
    out[dataset] = count;
  }
});
console.log(JSON.stringify(out, null, '  '));
