const assert = require('node:assert/strict');
const test = require('node:test');
const { visibleFeatures } = require('../app');

test('only enabled features appear', () => {
  assert.deepEqual(visibleFeatures(), ['ingest', 'dedupe', 'retry', 'metrics', 'batching']);
});
