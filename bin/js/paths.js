#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .option('-t, --tsv', 'print paths in tsv')
  .parse(process.argv);

let opts = program.opts();

const targetDatasets = ['ncbigene', 'ensembl_gene',
                        'ensembl_transcript', // Added in v2022-11
                        'uniprot', 'pdb', 'chebi', 'chembl_compound', 'pubchem_compound', 'glytoucan', 'mondo', 'mesh', 'nando', 'hp_phenotype', 'togovar'];

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
      let api = `http://sparql-support.dbcls.jp/sparqlist/api/togoid_route?source=${source}&target=${target}`;
      const promise = axios.get(api).then(res => {
        tmp[source][target] = res.data;
      }).catch(err => {
        console.error(err);
        process.exit(1);
      });
      promises.push(promise);
    }
  });
});

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
    // console.log(JSON.stringify(out, null, '  '));
    console.log(getJson(out));
  }
}).catch(err => {
  console.error(err);
});

function getJson(out) {
  let arr = [];
  Object.entries(out).forEach(([key, value]) => {
    arr.push(`  "${key}": {\n${getTargetPaths(value)}\n  }`);
  });
  return '{\n' + arr.join(',\n') + '\n}';
}

function getTargetPaths(value) {
  let arr = [];
  Object.entries(value).forEach(([target, paths]) => {
    arr.push(`    "${target}": [ ${getPaths(paths)} ]`);
  });
  return arr.join(',\n');
}

function getPaths(paths) {
  let arr = [];
  paths.forEach((path) => {
    arr.push(`[ ${getPath(path)} ]`);
  });
  return arr.join(', ');
}

function getPath(path) {
  let arr = [];
  path.forEach((node) => {
    arr.push(`"${node}"`);
  });
  return arr.join(', ');
}
