#!/usr/bin/env node
const program = require('commander');
const fs = require('fs');
const axios = require('axios');

program
  .option('-q, --quit', 'show config and quit')
  .option('-b, --branch <branch>', 'branch', 'develop')
  .option('--js', 'use jsdelivr instead of raw.githubusercontent')
  .parse(process.argv);

const opts = program.opts();

let uri = `https://raw.githubusercontent.com/togodx/togodx-config-human/${opts.branch}/config/`;
if (opts.js) {
  uri = `https://cdn.jsdelivr.net/gh/togodx/togodx-config-human@${opts.branch}/config/`;
}
uri += 'attributes.dx-server.json';

axios.get(uri).then(res => {
  if (opts.quit) {
    console.log(JSON.stringify(res.data, null, '  '));
    process.exit();
  } else {
    let header = ['category', 'label', 'description', 'dataset', 'datamodel'];
    console.log(header.join('\t'));
    res.data.categories.forEach((category) => {
      category.attributes.forEach((attrName) => {
        const attr = res.data.attributes[attrName];
        const fields = [category.label, attr.label, attr.description, attr.dataset, attr.datamodel];
        console.log(fields.join('\t'));
      });
    });
  }
}).catch(err => {
  console.error(err);
  process.exit(1);
});
