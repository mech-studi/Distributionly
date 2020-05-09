import React, {
    Component
} from "react";
import DomainKeeperContract from "./contracts/DomainKeeper.json";
import getWeb3 from "./getWeb3";

import "./App.css";

import Swal from 'sweetalert2'
import "../node_modules/sweetalert2/dist/sweetalert2.css";

import Noty from 'noty';
import "../node_modules/noty/lib/noty.css";
import "../node_modules/noty/lib/themes/sunset.css";

Noty.overrideDefaults({
    theme: 'sunset',
    timeout: 5000,
    type: 'info',
    progressBar: true
});

class App extends Component {
    state = {
        storageValue: 0,
        highestBid: 0,
        auctionEnd: 0,
        remainingTime: 0,
        inputValue: "",
        domainStatus: "",
        domainStatusText: "",
        searchedDomain: "",
        owner: "",
        owneripv4: "",
        owneripv6: "",
        buyButtonText: "",
        web3: null,
        accounts: null,
        contract: null,
        showDomainInfo: false,
    };

    componentDidMount = async () => {
        try {
            const web3 = await getWeb3();
            const accounts = await web3.eth.getAccounts();
            const networkId = await web3.eth.net.getId();
            const deployedNetwork = DomainKeeperContract.networks[networkId];
            const instance = new web3.eth.Contract(
                DomainKeeperContract.abi,
                deployedNetwork && deployedNetwork.address,
            );
            this.setState({
                web3,
                accounts,
                contract: instance
            }, this.runExample);
        } catch (error) {
            alert(
                `Failed to load web3, accounts, or contract. Check console for details.`,
            );
            console.error(error);
        }
    };

    runExample = async () => {
        const {
            web3,
            accounts,
            contract
        } = this.state;

        const containsObject = function(obj, list) {
            var i;
            for (i = 0; i < list.length; i++) {
                if (list[i].id === obj.id) {
                    return true;
                }
            }

            return false;
        }

        var connectedAtBlock = web3.eth.getBlockNumber();

        var prevNotifications = [];

        contract.events.AuctionStarted({}, (err, res) => {
            if (err) return;
            console.log("auction started");
            if (!containsObject(res, prevNotifications)) {
                prevNotifications.push(res);
                new Noty({
                    text: `The auction for domain ${res.returnValues.domain} has started, current bid is ${res.returnValues.amount} wei!`,
                }).show();
                if(res.returnValues.domain == this.state.searchedDomain){
                    this.updateDomainInfoPanel(this.state.searchedDomain, this);
                }
            }
        });
        contract.events.AuctionEnded({}, (err, res) => {
            if (err) return;
            if (!containsObject(res, prevNotifications)) {
                prevNotifications.push(res);
                    new Noty({
                        text: `The auction for domain ${res.returnValues.domain} has ended, with the highest bid of ${res.returnValues.amount} wei!`,
                        timeout: false,
                    })
                    .on('onClick', () => {
                        this.updateDomainInfoPanel(res.returnValues.domain, this);
                    })
                    .show();
                    if(res.returnValues.domain == this.state.searchedDomain){
                        this.updateDomainInfoPanel(this.state.searchedDomain, this);
                    }
            }
        });
        contract.events.HighestBidIncreased({}, (err, res) => {
            if (err) return;
            console.log("highest bid increased");
            if (!containsObject(res, prevNotifications)) {
                prevNotifications.push(res);
                    console.log(res.returnValues);
                    new Noty({
                        text: `The new highest bid on domain ${res.returnValues.domain} is ${res.returnValues.amount} wei.`,
                    }).show();
                    console.log(res.returnValues.domain, this.state.searchedDomain);
                    if(res.returnValues.domain == this.state.searchedDomain){
                        this.state.contract.methods.getAuctionState(this.state.searchedDomain).call()
                        .then((res)=>{
                            this.handleAuctionState(res, this);
                        })
                        .catch((err)=>{
                            console.log(err);
                        });
                    }
            }
        });
    };

    handleChange = function(e) {
        this.setState({
            inputValue: e.target.value
        });
    };

    updateCountdown = function(until, domain, ths){
        console.log(domain, ths.state.searchedDomain);

        if(ths.state.searchedDomain == domain && this.state.auctionEnd == until){
            var n = Date.now();
            ths.setState({
                remainingTime: Math.max(0, (Math.round((until - n)/1000)))
            });
            if(n < until){
                setTimeout(() => {this.updateCountdown(until, domain, ths)}, 1000);
            }else{
                ths.checkAuctionEnd(domain, ths);
            }
        }
    }

    checkAuctionEnd = function(domainName, ths){
        ths.updateDomainInfoPanel(domainName, ths);
    }

    handleAuctionState = function(res, ths){
        var n = Date.now();
        var end = res[3] + "000";
        console.log(n, end);
        if(n > end){
            var statusText;
            var buyButtonText;
            if(res["1"] == ths.state.accounts[0]){
                statusText = "The auction has ended, and you won!";
                buyButtonText = "Claim";
            }else{
                statusText = "The auction has ended, but you did not win!";
                buyButtonText = "Withdraw";
            }
            ths.setState({
                domainStatusText: statusText,
                buyButtonText,
                highestBid: res["2"],
            });
            console.log("auction ended");
        }else{
            ths.setState({auctionEnd: parseInt(end), highestBid: res["2"],});
            this.updateCountdown(parseInt(end), res["0"], ths);
        }
        console.log(res);
    }

    updateDomainInfoPanel = async function(domainName, ths){
        var domainStatusText = "";
        var domainStatusOptions = {
            "free" : `${this.state.inputValue} is available!`,
            "inauction": `${this.state.inputValue} is currently being auctioned off!`,
            "registered" : `${this.state.inputValue} is already owned!`
        }
        var buyButtonTextOptions = {
            "free": "Bid",
            "inauction": "Bid higher",
            "registered": "Nope"
        }
        var domainStatus;
        var highestBid = 0;
        var buyButtonText;
        var owneripv4;
        var owneripv6;
        var owner;

        await ths.state.contract.methods.getDomainInfo(domainName).call()
        .then((res) => {
            domainStatus = res["0"];
            buyButtonText = buyButtonTextOptions[res["0"]];
            domainStatusText = domainStatusOptions[res["0"]];
            if(domainStatus == "registered"){
                owneripv4 = res[1];
                owneripv6 = res[2];
                owner = res[3];
                if(owner == ths.state.accounts[0].toString()){
                    buyButtonText = "Configure";
                }else{
                    buyButtonText = "";
                }
            }
            console.log(res);
            console.log(ths.state.accounts[0].toString());
            return res;
        })
        .then((res)=>{ //get highest bid if in an auction
            if(domainStatus == "inauction"){
                return ths.state.contract.methods.getAuctionStateBid(ths.state.searchedDomain).call()
                .then((res)=>{
                    highestBid = res;
                    console.log(res);
                })
                .catch((err)=>{
                    console.log(err);
                });
            }
        })
        .catch((err) => {
            console.log(err);
        });
        ths.setState({
            showDomainInfo: true,
            domainStatus,
            highestBid,
            domainStatusText,
            buyButtonText,
            ipv4: owneripv4,
            ipv6: owneripv6,
            owner,
            searchedDomain: domainName
        });
        if(domainStatus == "inauction"){
            await ths.state.contract.methods.getAuctionState(ths.state.searchedDomain).call()
            .then((res)=>{
                this.handleAuctionState(res, ths);
            })
            .catch((err)=>{
                console.log(err);
            });
        }
    }

    handleSearch = async function() {
        console.log(this.state.inputValue);
        var searchedDomain = this.state.inputValue;
        this.updateDomainInfoPanel(searchedDomain, this);
    }

    handleBuy = async function() {
        var buttonText = this.state.buyButtonText;
        if(buttonText == "Bid" || buttonText == "Bid higher"){
            Swal.fire({
                title: `How much would you like to bid on ${this.state.inputValue}?`,
                html: '<div><input id="swal-input1" class="swal2-input" type="number"></div>' +
                '<select id="swal-input2" class="swal2-select">' +
                '<option value="0">Wei</option>' +
                '<option value="3">Kwei</option>' +
                '<option value="6">Mwei</option>' +
                '<option value="9">Gwei</option>' +
                '<option value="12">MicroEther</option>' +
                '<option value="15">MilliEther</option>' +
                '<option value="18">Ether</option>' +
                '</select>',
                preConfirm: () => {
                    return [document.getElementById('swal-input1').value,
                    document.getElementById('swal-input2').value
                ]
            }
        })
            .then((res) => {
            if (res.value) {
                var amountString = res.value[0];
                var multiplier = parseInt(res.value[1]);
                var decimalMarker = "";

                if (amountString.includes(",")) {
                    decimalMarker = ",";
                } else if (amountString.includes(".")) {
                    decimalMarker = ".";
                }
                var i = multiplier;
                if (decimalMarker != "") {
                    var decimalIndex = amountString.indexOf(decimalMarker);
                    var decimals = amountString.length - decimalIndex - 1;
                    if (decimals <= i) {
                        decimalMarker = "";
                        amountString = amountString.slice(0, decimalIndex) + amountString.slice(decimalIndex + 1);
                        i -= decimals;
                    } else {
                        amountString = amountString.slice(0, decimalIndex) + amountString.slice(decimalIndex + 1);
                        amountString = amountString.slice(0, decimalIndex + i) + "." + amountString.slice(decimalIndex + i);
                        i = 0;
                    }
                }
                while (i > 0) {
                    amountString += "0";
                    i--;
                }

                console.log(amountString);

                this.state.contract.methods.bid(this.state.searchedDomain).send({
                    from: this.state.accounts[0],
                    value: amountString
                });
            }
        });
        }else if(buttonText == "Claim"){
            this.state.contract.methods.claim(this.state.searchedDomain).send({
                from: this.state.accounts[0]
            })
            .then(()=>{
                this.updateDomainInfoPanel(this.state.searchedDomain, this);
            })
            .catch((err)=>{console.log(err)});
        }else if(buttonText == "Withdraw"){
            this.state.contract.methods.withdraw(this.state.searchedDomain).call()
            .then((res)=>{
                console.log(res);
            })
            .catch((err)=>{
                console.log(err);
            });
        }else if(buttonText == "Configure"){
            Swal.fire({
                title: `Configure your values`,
                html: '<input placeholder="IPv4" id="swal-input1" class="swal2-input" type="text" minlength="7" maxlength="15" size="15" pattern="^((\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.){3}(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$">' +
                '<input placeholder="IPv6" id="swal-input2" class="swal2-input" <input type="text" pattern="^(([0-9a-fA-F]{1}|[1-9a-fA-F]{1}[0-9a-fA-F]{1,3}):){7}([0-9a-fA-F]{1}|[1-9a-fA-F]{1}[0-9a-fA-F]{1,3})$">',
                preConfirm: () => {
                    return [document.getElementById('swal-input1').value,
                    document.getElementById('swal-input2').value]
                }
            })
            .then((res)=>{
                if(res.value){
                    this.state.contract.methods.ConfigureDomain(this.state.searchedDomain, res.value[0], res.value[1]).send({
                        from: this.state.accounts[0]
                    })
                    .then(()=>{
                        this.updateDomainInfoPanel(this.state.searchedDomain, this);
                    });
                }
            });
        }
    }

    render() {
        if (!this.state.web3) {
            return <div > Loading Web3, accounts, and contract... < /div>;
        }
        return (
            < div className="App">
                < h1 id="main-title"> Search for a domain < /h1>
                < input id="main-input-box" placeholder="zcash.com" type="text" name="" value={ this.state.inputValue } onChange={ evt=> this.handleChange(evt)}/>
                < button id="main-search-button" type="button" name="button" onClick={ ()=> this.handleSearch()} > Search < /button>
                <div id="domain-info" className = {!this.state.showDomainInfo ? "hide" : ""}>
                    <h1>{this.state.domainStatusText}</h1>
                    <p className = {this.state.domainStatus == "inauction" ? "" : "hide"}>Highest bid: {this.state.highestBid} wei</p>
                    <p className = {this.state.domainStatus == "inauction" ? "" : "hide"}>Remaining time: {this.state.remainingTime} seconds</p>
                    <p className = {this.state.domainStatus == "registered" ? "" : "hide"}>Associated IPv4: {this.state.ipv4}</p>
                    <p className = {this.state.domainStatus == "registered" ? "" : "hide"}>Associated IPv6: {this.state.ipv6}</p>
                    <p className = {this.state.domainStatus == "registered" ? "" : "hide"}>Owner: {this.state.owner}</p>
                    < button id="main-buy-button" className = {this.state.buyButtonText == "" ? "hide" : ""} type="button" name="button" onClick={ ()=> this.handleBuy()} > {this.state.buyButtonText} < /button>
                </div>
            < / div>
        );

    }
}

export default App;
