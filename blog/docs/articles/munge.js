const fs = require('fs');

const files = fs.readdirSync('./');

const re = /\*.md/;

files.forEach(file => {
  if (file.endsWith('.md')) {
    const contents = fs.readFileSync();
  }
});
