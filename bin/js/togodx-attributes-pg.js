#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .option('-b, --branch <branch>', 'branch', 'develop')
  .option('-d, --debug', 'show URI and quit')
  .option('--js', 'use jsdelivr instead of raw.githubusercontent')
  .parse(process.argv);

const opts = program.opts();

let uri = `https://raw.githubusercontent.com/togodx/togodx-config-human/${opts.branch}/config/`;
if (opts.js) {
  uri = `https://cdn.jsdelivr.net/gh/dbcls/togosite@${opts.branch}/config/togosite-human/`;
}
uri += 'attributes.dx-server.json';

const color = {
  "Gene": "#3AA64C",
  "Protein": "#79A63A",
  "Structure": "#A6823A",
  "Interaction": "#A63A43",
  "Compound": "#A63A94",
  "Glycan": "#673AA6",
  "Disease": "#3A5EA6",
  "Variant": "#3AA69D",
}

let arr = [];
if (opts.debug) {
  console.log(uri);
} else {
  axios.get(uri).then(res => {
    printAttributes(res.data);
  }).catch(err => {
    console.error(err);
    process.exit(1);
  });
}

function printAttributes(obj) {
  const attrs = obj.attributes;
  const attrMap = new Map();
  obj.categories.forEach((category) => {
    category.attributes.forEach((attrId) => {
      console.log(`${attrId} -- ${attrs[attrId].dataset}`);
      attrMap.set(attrId, category.label);
    });
  });
  console.log();
  attrMap.forEach((category, attrId) => {
    console.log(`${attrId}`);
    console.log(`  :Attribute`);
    console.log(`  category: "${category}"`);
    console.log(`  dataset: "${attrs[attrId].dataset}"`);
    console.log(`  size: 15`);
    console.log(`  color: "${color[category]}"`);
  });
}
