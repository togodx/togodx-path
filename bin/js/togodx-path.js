#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .parse(process.argv);

let opts = program.opts();

const targetDatasets = ['ncbigene', 'ensembl_gene', 'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp', 'togovar'];

let out = {};
let promises = [];
targetDatasets.forEach((source) => {
  targetDatasets.forEach((target) => {
    if (source !== target) {
      let api = `https://integbio.jp/togosite_dev/sparqlist/api/togoid_route?source=${source}&target=${target}`;
      const promise = axios.get(api).then(res => {
        const obj = {};
        obj[target] = res.data;
        out[source] = obj;
      }).catch(err => {
        console.error(err);
        process.exit(1);
      });
      promises.push(promise);
    }
  });
});

Promise.all(promises).then(() => {
  console.log(JSON.stringify(out, null, '  '));
});
