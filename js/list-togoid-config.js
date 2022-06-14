#!/usr/bin/env node
const axios = require('axios');

axios.get('https://api.github.com/repos/togoid/togoid-config/git/trees/main').then(res => {
  json = JSON.parse(JSON.stringify(res.data));
  for (let dir of json.tree) {
    if (dir.path === 'config') {
      listConfigDir(dir.url);
    }
  }
}).catch(err => {
  console.error(err);
});;

function listConfigDir(url) {
  axios.get(url).then((res) => {
    json = JSON.parse(JSON.stringify(res.data));
    for (let dir of json.tree) {
      if (dir.path.includes('-')) {
        console.log(dir.path);
      }
    }
  }).catch(err => {
    console.error(err);
  });
}
