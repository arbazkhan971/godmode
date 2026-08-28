// Contact records for the roster tool. Array order is the on-file order.
'use strict';

const CONTACTS = [
  { first: 'Grace', last: 'Hopper', email: 'grace@example.net' },
  { first: 'Ada', last: 'Lovelace', email: 'ada@example.net' },
  { first: 'Pierre', last: 'Curie', email: 'pierre@example.net' },
  { first: 'Alan', last: 'Turing', email: 'alan@example.net' },
  { first: 'Marie', last: 'Curie', email: 'marie@example.net' },
  { first: 'Katherine', last: 'Johnson', email: 'katherine@example.net' },
  { first: 'Edsger', last: 'Dijkstra', email: 'edsger@example.net' },
  { first: 'Zoë', last: 'Lane', email: 'zoe@example.net' },
  { first: 'Barbara', last: 'Liskov', email: 'barbara@example.net' },
  { first: 'Donald', last: 'Knuth', email: 'donald@example.net' },
  { first: 'Radia', last: 'Perlman', email: 'radia@example.net' },
];

function load() {
  return CONTACTS.slice();
}

module.exports = { load };
