import { test } from 'node:test';
import assert from 'node:assert/strict';
import { precioFinal } from '../src/descuento.js';

test('un socio que compra 100 € paga 90 €', () => {
  assert.equal(precioFinal(10000, true), 9000);
});

test('quien no es socio paga el precio completo', () => {
  assert.equal(precioFinal(20000, false), 20000);
});
