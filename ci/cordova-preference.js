const fs = require("fs");
const path = require("path");
const xpath = require("xpath");
const DOMParser = require("@xmldom/xmldom").DOMParser;

if (process.argv.length !== 5) {
    throw new Error("Expected path, preference key and value.");
}

const srcFn = path.join(process.argv[2], "config.xml");
const preference = process.argv[3];
const preferenceValue = process.argv[4];

const srcXml = fs.readFileSync(srcFn, "utf8");

const select = xpath.useNamespaces({ x: "http://www.w3.org/ns/widgets" });
const doc = new DOMParser().parseFromString(srcXml);
const nodes = select(`//x:preference[@name='${preference}']/@value`, doc);
if (nodes.length) {
    nodes[0].value = preferenceValue;
} else {
    // Add elem
    const prefElem = doc.createElement("preference");
    const nameAttr = doc.createAttribute("name");
    nameAttr.value = preference;
    prefElem.setAttributeNode(nameAttr);
    const valueAttr = doc.createAttribute("value");
    valueAttr.value = preferenceValue;
    prefElem.setAttributeNode(valueAttr);
    doc.documentElement.appendChild(prefElem);
}

const tgtXml = doc.toString();
if (tgtXml !== srcXml) {
    fs.writeFileSync(srcFn, tgtXml, "utf8");
}
