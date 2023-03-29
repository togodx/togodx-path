#!/usr/bin/env node
const program = require('commander');
const fs = require('fs');

program
  .arguments('[INPUT]')
  .parse(process.argv);

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

const obj = JSON.parse(input);
Object.entries(obj).forEach(([key, value]) => {
  Object.entries(value).forEach(([target, paths]) => {
    printPaths(paths);
  });
});

function printPaths(paths) {
  paths.forEach((path) => {
    for (let i = 0; i < path.length - 1; i++) {
      console.log(path[i] + '\t' + path[i + 1]);
    }
  });
}
