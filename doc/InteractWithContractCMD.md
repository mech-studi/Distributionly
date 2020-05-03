let service = await DomainKeeper.deployed()
let sa = await SimpleAuction.deployed()

await service.bid('test.org', {from:accounts[0], value:2})
await service.bid('test.org', {from:accounts[1], value:3})


await service.getAuctionState('test.org')
await service.getAuctionStateReturns('acc.org', {from:accounts[3]})

await service.addDomain('heinz', 'test.org')
await service.getOwner(1)


truffle migrate --compile-all