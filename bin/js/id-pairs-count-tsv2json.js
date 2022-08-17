#!/usr/bin/env node
const program = require('commander');
const fs = require('fs');

program
  .option('-c, --combinations', 'Number of combinations of ID pairs')
  .option('-v, --verbose', 'verbose')
  .arguments('[INPUT]')
  .parse(process.argv);

const opts = program.opts();

const targetDatasets = ['ncbigene', 'ensembl_gene', 'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp', 'togovar'];

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
targetDatasets.forEach((source) => {
  out[source] = {};
});
lines.forEach((line) => {
  let source, target, count1, count2, combinations;
  [source, target, count1, count2, combinations] = line.split('\t');
  if (opts.combinations) {
    if (out[source][target]) {
      console.error('already checked ${source}-${target}');
    }
    out[source][target] = combinations;
    if (out[target][source]) {
      console.error('already checked ${target}-${source}');
    }
    out[target][source] = combinations;
  } else {
    if (!out[source][target]) {
      out[source][target] = {};
    }
    out[source][target].start = count1;
    out[source][target].end = count2;
    out[source][target].combinations = combinations;
    if (!out[target][source]) {
      out[target][source] = {};
    }
    out[target][source].start = count2;
    out[target][source].end = count1;
    out[target][source].combinations = combinations;
  }
});
console.log(JSON.stringify(out, null, '  '));
