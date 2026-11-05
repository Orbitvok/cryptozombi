// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ZombieFactory} from "../src/ZombieFactory.sol";

contract ZombieFactoryTest is Test {
    ZombieFactory factory;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        factory = new ZombieFactory();
    }

    // 01. Создание: верный id, имя, владелец и время; счётчики увеличились
    function test_SuccessfulZombieCreation() public {
        vm.prank(alice);
        uint256 id = factory.createZombie("AliceZombie");

        (string memory name,, uint256 createdAt) = factory.getZombie(id);
        assertEq(id, 0);
        assertEq(name, "AliceZombie");
        assertEq(factory.zombieToOwner(id), alice);
        assertEq(createdAt, block.timestamp);
        assertEq(factory.totalZombies(), 1);
    }

    // 02. Два разных адреса: каждый создаёт своего зомби, id различаются
    function test_TwoDifferentOwners() public {
        vm.prank(alice);
        uint256 aliceId = factory.createZombie("AliceZombie");

        vm.prank(bob);
        uint256 bobId = factory.createZombie("BobZombie");

        assertEq(aliceId, 0);
        assertEq(bobId, 1);
        assertEq(factory.totalZombies(), 2);
        assertEq(factory.zombieToOwner(aliceId), alice);
        assertEq(factory.zombieToOwner(bobId), bob);
    }

    // 03. Пустое имя: vm.expectRevert с сообщением "Empty name"
    function test_FailEmptyName() public {
        vm.prank(alice);
        vm.expectRevert("Empty name");
        factory.createZombie("");
    }

    // 04. Повторный вызов одного владельца: "Already has zombie"
    function test_FailDuplicateZombie() public {
        vm.prank(alice);
        factory.createZombie("FirstZombie");

        vm.prank(alice);
        vm.expectRevert("Already has zombie");
        factory.createZombie("SecondZombie");
    }

    // 05. ДНК: для созданного зомби значение меньше DNA_MODULUS
    function test_DnaIsWithinBoundaries() public {
        vm.prank(alice);
        uint256 id = factory.createZombie("AliceZombie");

        (, uint256 dna,) = factory.getZombie(id);
        assertLt(dna, factory.DNA_MODULUS());
    }
}
