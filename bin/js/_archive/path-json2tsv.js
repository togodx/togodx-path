#!/usr/bin/env node

const input = require("fs").readFileSync("/dev/stdin", "utf8");
const json = JSON.parse(input);
const keys = Object.keys(json);
keys.forEach((source) => {
  keys.forEach((target) => {
    if (source !== target) {
      json[source][target].forEach((path) => {
        console.log(source + '-' + target + '\t' + path.join('-'));
      });
    }
  });
});
