#!/usr/bin/env node
const program = require('commander');
const fs = require('fs');
const axios = require('axios');

program
  .option('-d, --dataset', 'count IDs for each dataset')
  .option('-j, --json', 'output JSON to stdout')
  .option('-l, --list', 'list all IDs')
  .option('-q, --quit', 'show config and quit')
  .option('-v, --verbose', 'verbose')
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
    if (opts.json) {
      let out = {};
      for (let i=0; i<datasets.length; i++) {
        out[datasets[i]] = String(datasetIdMaps[i].size);
      }
      console.log(JSON.stringify(out, null, '  '));
    } else if (opts.dataset) {
      const header = ['dataset', 'count_ids'];
      console.log(header.join('\t'));
      for (let i=0; i<datasets.length; i++) {
        console.log(datasets[i] + '\t' + datasetIdMaps[i].size);
      }
    } else if (opts.list) {
      for (let i=0; i<datasets.length; i++) {
        for (let key of datasetIdMaps[i].keys()) {
          console.log(`${datasets[i]}\t${key}`);
        }
      }
    } else {
      printAttributes(res.data);
    }
  }
}).catch(err => {
  console.error(err);
  process.exit(1);
});

function printAttributes(obj) {
  let header = [
    'category',
    'label',
    'description',
    'dataset',
    'datamodel',
    // 'count_ids'
  ];
  if (opts.verbose) {
    header.pop();
    header.push('unique_count', 'redundant_count', 'DAG_check');
  }
  console.log(header.join('\t'));
  const attrs = obj.attributes;
  obj.categories.forEach((category) => {
    category.attributes.forEach((attrName) => {
      try {
        const fields = [category.label,
                        attrs[attrName].label,
                        attrs[attrName].description,
                        attrs[attrName].dataset,
                        attrs[attrName].datamodel];
        console.log(fields.join('\t'));
      } catch (err) {
        console.error(`cannot parse ${attrName}`);
        process.exit(1);
      }
    });
  });
}
