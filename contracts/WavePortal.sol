// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    /**
     *  El mapping nos permite asociar una address con un numero que va ser
     *  facil de identificar.
     */
    mapping(address => uint256) public lastWavedAt;

    /**
    * event nos permite loggearnos a la blockchain de ETH.
    * Es usado para escuchar eventos y hacer updates de forma barata sobre el storage 
    */

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    constructor() payable {
        seed = (block.timestamp + block.difficulty) % 100;
    }

    //_message es enviado por el front.
    function wave(string memory _message) public {
        /*
         * Esto va a restringir aquellas address que tienen menos de 15 min.
         */
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Espera 15m"
        );

        /*
         * Actualizamos el timestamp de una address almacenada en el mapping
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s Wave generada con w/ message %s", msg.sender, _message);
        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Semilla random generada", seed);

        //oportunidad del 50% en recibir prizeAmount
        if (seed <= 50) {
            console.log("%s gano el prizeAmount!", msg.sender);
            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Se esta tratando de retirar mas dinero del que el contrato posee"
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Error al retirar dinero del contrato.");
        }

        /**
         * emit nos permite emitir un evento dentro de solidity
         * que puede ser leido por el cliente.
         * Usado para logear los eventos de la blockchain
         */
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("Se tienen %d un total de waves!", totalWaves);
        return totalWaves;
    }
}
