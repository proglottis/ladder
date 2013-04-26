Ladder.Adapter = DS.RESTAdapter.extend()
Ladder.Adapter.map 'Ladder.Game',
  gameRanks: { embedded: 'load' }

Ladder.Store = DS.Store.extend
  revision: 11
  adapter: Ladder.Adapter.create()
