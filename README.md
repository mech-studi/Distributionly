#  Distributionly a Blockchain-based DNS

## Brief Description & Ideation

The goal of this project is to rebuild the basic functionality of a Domain Name System (DNS) based on a blockchain and smart contracts.

![Use Case Diagram](./doc/images/Distributionly-Diagrams-UseCase.png "Use Cases")

The system must be able to resolve human-readable names to technical addresses such as IPv4, IPv6 (and maybe even blockchain .bit .eth or IPFS addresses). Technical top-level domains are managed by the system administrator. A domain owner can then register his subdomain to a known top level domain. A sub domain can have other sub domains. Optionally the system could provide a domain rating system or a domain certification service (note that X.509 PKI functionality is out of scope). 

A simple domain rating system could be that everyone except the domain owner can up-/downvote the domain. The domain owner cannot vote for his domain, but can flush all the ratings of his domain (yes ... this needs much refinement ^^'').

The name resolver functionality can be implemented in an external python script or a smart contract. 

The registration and the certification of a subdomain costs ether.

![Container Diagram](./doc/images/Distributionly-Diagrams-C2-Container.png "Container Diagram")

## Addressing BCOLN Requirements

1. The core functionality must be implemented and executed entirely within Smart Contracts (SC).

    - Manage top-level domains
    - Manage subdomains and zone file entries
    - Resolve names? 

1. The SC must implement an economic aspect, e.g., a payment system, incentives, gambling, or any economy-related functionality.

    - Pay for subdomain entries
    - Pay for subdomain entry certification?

1. The user must interact with the DApp via a Graphical User Interface (GUI), for example, a Web-based one.

    - Web interface to query names and display DNS entries

1. The group must deliver a self-contained report documenting the SC, its operation, and the source code.

    - OK =.=

