#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .option('-t, --tsv', 'list edges of paths in tsv')
  .parse(process.argv);

let opts = program.opts();

const targetDatasets = ['ncbigene', 'ensembl_gene', 'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp', 'togovar'];

let tmp = {};
let out = {};
targetDatasets.forEach((source) => {
  tmp[source] = {};
  out[source] = {};
});

let promises = [];
targetDatasets.forEach((source) => {
  targetDatasets.forEach((target) => {
    if (source !== target) {
      let api = `https://integbio.jp/togosite_dev/sparqlist/api/togoid_route?source=${source}&target=${target}`;
      const promise = axios.get(api).then(res => {
        if (opts.tsv) {
          printPaths(res.data);
        } else {
          tmp[source][target] = res.data;
        }
      }).catch(err => {
        console.error(err);
        process.exit(1);
      });
      promises.push(promise);
    }
  });
});

if (!opts.tsv) {
  Promise.all(promises).then(() => {
    targetDatasets.forEach((source) => {
      targetDatasets.forEach((target) => {
        if (source !== target) {
          out[source][target] = tmp[source][target];
        }
      });
    });
    console.log(JSON.stringify(out, null, '  '));
  }).catch(err => {
    console.error(err);
  });
}

function printPaths(paths) {
  paths.forEach((path) => {
    for (let i = 0; i < path.length - 1; i++) {
      console.log(path[i] + '\t' + path[i + 1]);
    }
  });
}
