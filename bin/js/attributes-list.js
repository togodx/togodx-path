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

const datasets = ['ncbigene', 'ensembl_gene', 'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp', 'togovar'];
let datasetIdMaps = [];
for (let i=0; i<datasets.length; i++) {
  datasetIdMaps[i] = new Map();
}

axios.get(uri).then(res => {
  if (opts.quit) {
    console.log(JSON.stringify(res.data, null, '  '));
    process.exit();
  } else {
    const obj = res.data;
    let header = [
      'category',
      'label',
      'description',
      'dataset',
      'datamodel',
    ];
    console.log(header.join('\t'));
    obj.categories.forEach((category) => {
      category.attributes.forEach((attrName) => {
        try {
          const attr = obj.attributes[attrName];
          const fields = [category.label,
                          attr.label,
                          attr.description,
                          attr.dataset,
                          attr.datamodel];
          console.log(fields.join('\t'));
        } catch (err) {
          console.error(`cannot parse ${attrName}`);
          process.exit(1);
        }
      });
    });
  }
}).catch(err => {
  console.error(err);
  process.exit(1);
});
