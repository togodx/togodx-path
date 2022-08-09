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
  .arguments('[DIR]')
  .parse(process.argv);

const opts = program.opts();

if (program.args.length) {
  process.chdir(program.args[0]);
} else {
  program.help();
}

let uri = `https://raw.githubusercontent.com/togodx/togodx-config-human/${opts.branch}/config/`;
if (opts.js) {
  uri = `https://cdn.jsdelivr.net/gh/togodx/togodx-config-human@${opts.branch}/config/`;
}
uri += 'attributes.dx-server.json';

const datasets = ['chebi', 'chembl_compound', 'ensembl_gene', 'glytoucan', 'hp', 'mesh', 'mondo', 'nando', 'ncbigene', 'pdb', 'pubchem_compound', 'togovar', 'uniprot'];
let datasetIdMaps = [];
for (let i=0; i<datasets.length; i++) {
  datasetIdMaps[i] = new Map();
}

axios.get(uri).then(res => {
  if (opts.quit) {
    console.log(JSON.stringify(res.data, null, '  '));
    process.exit();
  } else {
    const attributesCount = printAttributes(res.data);
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
      console.log(attributesCount);
    }
  }
}).catch(err => {
  console.error(err);
  process.exit(1);
});

function printAttributes(obj) {
  let out = [];
  if (!opts.verbose) {
    const header = ['attribute', 'dataset', 'datamodel', 'count_ids'];
    out.push(header.join('\t'));
  }
  const attrs = obj.attributes;
  obj.categories.forEach((category) => {
    if (opts.verbose) {
      out.push('')
      out.push(`== ${category.label} ==`);
    }
    category.attributes.forEach((attrName) => {
      try {
        out.push(parseJson(attrName, attrs[attrName]));
      } catch (err) {
        console.error(`cannot parse ${attrName}`);
        process.exit(1);
      }
    });
  });
  return out.join('\n');
}

function parseJson(attrName, attrObj) {
  let uniqIds = new Map();
  let totalCount = 0;
  let isDAG = false;
  let countDAG = 0;
  let dagExample = '';
  let rootId;
  let mapParent = new Map();

  let input = fs.readFileSync(attrName, "utf8");
  JSON.parse(input.toString()).forEach((elem) => {
    if (!elem.id) {
      console.error(elem);
    }

    if (attrObj.datamodel === 'distribution') {
      totalCount++;
      uniqIds.set(elem.id, true);
      saveDatasetId(attrObj.dataset, elem.id);
    } else {
      if (elem.root) {
        checkRoot(elem);
      } else if (elem.leaf === true) {
        totalCount++;
        uniqIds.set(elem.id, true);
        saveDatasetId(attrObj.dataset, elem.id);
      } else if (elem.parent) {
        if (mapParent.has(elem.id)) {
          isDAG = true;
          countDAG++;
          dagExample = `${elem.id} (${elem.label})` + ' -> ' + mapParent.get(elem.id) + ', ' + elem.parent;
        } else {
          mapParent.set(elem.id, elem.parent)
        }
      }
    }
  });

  let out = `${attrName}\t${attrObj.dataset}\t${attrObj.datamodel}\t${uniqIds.size}`
  if (opts.verbose) {
    out = '\n';
    out += `# ${uniqIds.size}\t${attrObj.dataset}\t${attrName}\t${attrObj.datamodel}`;
    if (uniqIds.size !== totalCount) {
      out += `\n${totalCount} ids`;
    }
    if (isDAG) {
      out += `\nDAG ${countDAG} ex. ${dagExample}`;
    }
  }
  return out;

  function checkRoot (elem) {
    if (elem.root === true) {
      if (rootId) {
        console.error('error: rootId=', rootId);
      }
      rootId = elem.id;
    } else {
      console.error('error: root is', elem);
    }
  }
}

function saveDatasetId(dataset, id) {
  const i = datasets.indexOf(dataset);
  datasetIdMaps[i].set(id, true);
}
