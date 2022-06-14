#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .option('-v, --verbose', 'verbose')
  .parse(process.argv);

let opts = program.opts();

const targetDatasets = ['ncbigene', 'ensembl_gene', 'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp', 'togovar'];

targetDatasets.forEach((source) => {
  targetDatasets.forEach((target) => {
    if (source !== target) {
      let api = `https://integbio.jp/togosite_dev/sparqlist/api/togoid_route?source=${source}&target=${target}`;
      axios.get(api).then(res => {
        if (opts.verbose) {
          console.log();
          console.log(api);
        }
        printPaths(res.data);
      }).catch(err => {
        console.error(`cannot open ${api}`);
        process.exit(1);
      });
    }
  });
});

function printPaths(paths) {
  paths.forEach((path) => {
    if (opts.verbose) {
      console.log(path);
    }
    for (let i = 0; i < path.length - 1; i++) {
      console.log(path[i] + '\t' + path[i + 1]);
    }
  });
}
