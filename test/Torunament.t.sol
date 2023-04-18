// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/Tournament.sol";
import "lib/openzeppelin-contracts/contracts/utils/Timers.sol";

contract CounterTest is Test {

    Tournament public tournament;
    using Timers for Timers.Timestamp;
    Timers.Timestamp private executionTime;


    address admin;
    address alice;
    address bob;
    address eve;

    function setUp() public {
        admin = vm.addr(1);
        alice = vm.addr(2);
        bob = vm.addr(3);
        eve = vm.addr(4);

        vm.deal(admin, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);

        vm.prank(admin);
        tournament = new Tournament();
    }

    function testCreateTournament() public {
        vm.prank(admin);
        tournament.createTournament(3, 1000);
        bool iscreated;
        (iscreated, , , , , , ) = tournament.getTournamentsData(1);
        assertEq(iscreated, true);
    }

    function testCreateTournamentRevertWhenCallerIsNotAdmin() public {
        vm.expectRevert(bytes("Caller is not admin"));
        tournament.createTournament(3, 1000);
    }

    function testCreateTournamentRevertWhenTotalUserLimitIsZero() public {
        vm.expectRevert(bytes("User Limit Can Not Be Zero"));
        vm.prank(admin);
        tournament.createTournament(0, 1000);
    }

    function testCreateTournamentRevertWhenTournamenrDurationIsZero() public {
        vm.expectRevert(bytes("Tournament Duration Can Not Zero"));
        vm.prank(admin);
        tournament.createTournament(3, 0);
    }

    function testJoinTournament() public {
        vm.prank(admin);
        tournament.createTournament(1, 100);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        address[] memory participants;
        (, , , , , , participants) = tournament.getTournamentsData(1);
        assertEq(participants[0], alice);
    }

    function testJoinTournamentRevertWhenTournamnetDoesNotExist() public {
        vm.expectRevert(bytes("Tournament Does Not Exist"));
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
    }

    function testJoinTournamentRevertWhenTournamnetUserLimitReached() public {
        vm.prank(admin);
        tournament.createTournament(1, 100);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.expectRevert(bytes("Tournament User Limit Reached"));
        vm.prank(bob);
        tournament.joinTournament{value: 2 ether}(1);
    }

    function testJoinTournamentRevertWhenUserTryToJoinWithoutStack() public {
        vm.prank(admin);
        tournament.createTournament(1, 100);
        vm.expectRevert(bytes("For Join Touranament User Must Stack 2 Matic"));
        vm.prank(alice);
        tournament.joinTournament{value: 0 ether}(1);
    }

    function testJoinTournamentRevertWhenAdminTryToJoin() public {
        vm.prank(admin);
        tournament.createTournament(1, 100);
        vm.expectRevert(bytes("Admin Can Not Join Tournament"));
        vm.prank(admin);
        tournament.joinTournament{value: 2 ether}(1);
    }

    function teststartTournament() public {
        vm.prank(admin);
        tournament.createTournament(1, 100);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(admin);
        tournament.startTournament(1);
        bool isStarted;
        (, isStarted, , , , , ) = tournament.getTournamentsData(1);
        assertEq(isStarted, true);
    }

    function teststartTournamentRevertWhenUserLimitNotReached() public {
        vm.prank(admin);
        tournament.createTournament(2, 100);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.expectRevert(bytes("User Limit Not Reached"));
        vm.prank(admin);
        tournament.startTournament(1);
    }

    function teststartTournamentRevertWhenTournamentStarted() public {
        vm.prank(admin);
        tournament.createTournament(1, 100);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(admin);
        tournament.startTournament(1);
        vm.expectRevert(bytes("Tournament Allready Started"));
        vm.prank(admin);
        tournament.startTournament(1);
    }

     function testendTournament() public {
        vm.prank(admin);
        tournament.createTournament(2, 1);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(bob);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(admin);
        tournament.startTournament(1);
        vm.prank(admin);
        tournament.endTournament(1, alice);
        bool isended;
        (, , isended , , , , ) = tournament.getTournamentsData(1);
        assertEq(isended, true);
    }

    function testendTournamentRevertIfTournamentTimeISNotReverted() public {
        vm.prank(admin);
        tournament.createTournament(2, 100);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(bob);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(admin);
        tournament.startTournament(1);
        vm.expectRevert(bytes("Tournament Duration Time Is Not Over At"));
        vm.prank(admin);
        tournament.endTournament(1, alice);
    }

    function testendTournamentRevertIfTournamentTimeISNotStarted() public {
        vm.prank(admin);
        tournament.createTournament(2, 1);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(bob);
        tournament.joinTournament{value: 2 ether}(1);
        vm.expectRevert(bytes("Tournament Does Not Started"));
        vm.prank(admin);
        tournament.endTournament(1, alice);
    }


    function testendTournamentRevertIfTournamentIsEnded() public {
        vm.prank(admin);
        tournament.createTournament(2, 1);
        vm.prank(alice);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(bob);
        tournament.joinTournament{value: 2 ether}(1);
        vm.prank(admin);
        tournament.startTournament(1);
        vm.prank(admin);
        tournament.endTournament(1, alice);
        vm.expectRevert(bytes("Tournament Allready Ended"));
        vm.prank(admin);
        tournament.endTournament(1, alice);
    }



}