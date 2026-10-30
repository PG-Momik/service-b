const features = require('./features.json');

function visibleFeatures() {
  return features.filter((feature) => feature.enabled).map((feature) => feature.name);
}

if (require.main === module) console.log(visibleFeatures().join(', '));

module.exports = { visibleFeatures };
