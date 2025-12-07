const fs = require('fs');
const path = require('path');

const fxmanifestPath = path.join(__dirname, '../fxmanifest.lua');

fs.readFile(fxmanifestPath, 'utf8', function (err, data) {
    if (err) throw err;

    if (process.env.NODE_ENV === 'development') {
        data = data.replace(/web\/dist\/index\.html/g, 'web/shim.html');
    } else {
        data = data.replace(/web\/shim\.html/g, 'web/dist/index.html');
    }

    fs.writeFile(fxmanifestPath, data, function(err) {
        if (err) throw err;
        console.log('fxmanifest.lua updated for', process.env.NODE_ENV || 'production');
    });
});

