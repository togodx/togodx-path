#!/usr/bin/env node
const program = require('commander');
const axios = require('axios');

program
  .option('-v, --verbose', 'verbose')
  .parse(process.argv);

let opts = program.opts();

axios.get('https://api.github.com/repos/togoid/togoid-config/git/trees/main').then(res => {
  if (opts.verbose) {
    console.log(res.data);
  }
  for (let dir of res.data.tree) {
    if (dir.path === 'config') {
      listConfigDir(dir.url);
    }
  }
}).catch(err => {
  console.error(err);
});

function listConfigDir(configDir) {
  axios.get(configDir).then((res) => {
    for (let dir of res.data.tree) {
      if (dir.path.includes('-')) {
        console.log(dir.path);
      }
    }
  }).catch(err => {
    console.error(err);
  });
}
