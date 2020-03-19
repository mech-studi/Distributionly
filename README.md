#  Distributionly a Blockchain-based DNS

`This project is an assignment for the BCOLN lecture at the University of Zurich.`

## Brief Description & Ideation

The goal of this project is to rebuild the basic functionality of a Domain Name System (DNS) based on a blockchain and smart contracts.

![Use Case Diagram](./doc/images/Distributionly-Diagrams-UseCase.png "Use Cases")

The system must be able to resolve human-readable names to technical addresses. A domain owner can register his subdomain to a known top level domain. A subdomain can have other subdomains. Optionally the system could allow a domain abuse rating system or a domain certification service (note that X.509 PKI functionality is out of scope). 

- A simple domain abuse reporting system could be that everyone except the domain owner report incorrect behavior. The domain owner can flush all reported missusages and reset his domain `TODO: refine reporting concept`.
- The focus lies on IPv4 and IPv6 addresses. Other address schemes are out of scope for this project. Technical top-level domains are managed by the system administrator.
- The name resolver functionality can be implemented in an external python script or a smart contract. 
- The registration and the certification of a subdomain costs ether. Can we buy or bid on a domain name? `TODO: refine economic concept`.
- Bootstraping and registration of top level domains is out of scope. 


![Container Diagram](./doc/images/Distributionly-Diagrams-C2-Container.png "Container Diagram")

## Addressing BCOLN Requirements

1. The core functionality must be implemented and executed entirely within Smart Contracts (SC).

    - Manage top-level domains
    - Manage subdomains and zone file entries
    - Resolve names? 

1. The SC must implement an economic aspect, e.g., a payment system, incentives, gambling, or any economy-related functionality.

    - Pay for subdomain entries
    - Pay for subdomain entry certification?
    - Buy a subdomain from someone
    - Bid for a subdomain

1. The user must interact with the DApp via a Graphical User Interface (GUI), for example, a Web-based one.

    - Web interface to query names and display DNS entries

1. The group must deliver a self-contained report documenting the SC, its operation, and the source code.

    - OK =.=

