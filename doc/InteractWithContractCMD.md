let service = await DomainKeeper.deployed()

await service.bid('test.org', {from:accounts[0], value:2})