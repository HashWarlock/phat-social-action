// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHelloWorld} from "./interfaces/IHelloWorld.sol";
import {PhatRollupAnchor} from "../lib/phat/PhatRollupAnchor.sol";

contract HelloWorld is IHelloWorld {
    event Greet(string message, address actor);
    event ResponseReceived(uint reqId, string reqData, string value);
    event ErrorReceived(uint reqId, string reqData, string errno);

    uint constant TYPE_RESPONSE = 0;
    uint constant TYPE_ERROR = 2;

    mapping(uint => string) requests;
    uint nextRequest = 1;

    constructor(address phatAttestor) {
        _grantRole(PhatRollupAnchor.ATTESTOR_ROLE, phatAttestor);
    }

    function helloWorld(string memory message, address actor) external {
        uint id = nextRequest;
        requests[id] = reqData;
        _pushMessage(abi.encode(id, message));
        nextRequest += 1;
        emit Greet(string(abi.encodePacked("Hello, World From Open Action  ", message)), actor);
    }

    function _onMessageReceived(bytes calldata action) internal override {
        // Optional to check length of action
        // require(action.length == 32 * 3, "cannot parse action");
        (uint respType, uint id, string memory data) = abi.decode(
            action,
            (uint, uint, string)
        );
        if (respType == TYPE_RESPONSE) {
            emit ResponseReceived(id, requests[id], data);
            delete requests[id];
        } else if (respType == TYPE_ERROR) {
            emit ErrorReceived(id, requests[id], data);
            delete requests[id];
        }
    }
}
