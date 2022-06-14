#!/usr/bin/env node
const axios = require('axios');

axios.get('https://api.github.com/repos/togoid/togoid-config/git/trees/main').then(res => {
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
