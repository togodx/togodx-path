#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .option('-l, --list', 'list edges of paths in tsv')
  .option('-t, --tsv', 'print paths in tsv')
  .parse(process.argv);

let opts = program.opts();

const targetDatasets = ['ncbigene', 'ensembl_gene',
                        'ensembl_transcript', // Added in v2022-11
                        'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp', 'togovar'];

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
      // let api = `http://ep.dbcls.jp/togoid/sparqlist/api/togodx_route?source=${source}&target=${target}`;
      const promise = axios.get(api).then(res => {
        if (opts.list) {
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

if (!opts.list) {
  Promise.all(promises).then(() => {
    targetDatasets.forEach((source) => {
      targetDatasets.forEach((target) => {
        if (source !== target) {
          if (opts.tsv) {
            tmp[source][target].forEach((path) => {
              console.log(source + '-' + target + '\t' + path.join('-'));
            });
          } else {
            out[source][target] = tmp[source][target];
          }
        }
      });
    });
    if (!opts.tsv) {
      console.log(JSON.stringify(out, null, '  '));
    }
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
