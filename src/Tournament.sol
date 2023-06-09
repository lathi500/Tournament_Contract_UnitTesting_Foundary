//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tournament {
    struct tournamentsData {
        bool isCreated;
        bool isStarted;
        bool isEnded;
        uint totalUserLimit;
        uint256 tournamentStartTime;
        uint256 tournamentDurationTime;
        address[] participants;
    }

    mapping(uint => tournamentsData) tournamentsList;
    address public admin;
    uint totalTournaments;

    constructor() {
        admin = msg.sender;
    }

    /** smart contract deployer will be our admin */

    modifier onleyAdmin() {
        require(msg.sender == admin, "Caller is not admin");
        _;
    }

    event tournamentStarted(
        uint256 tournamentNumber,
        uint256 tournamentStartTime,
        uint256 tournamentDuration
    );

    /**
     * @dev Platfrom admin can create an new tournaments.
     * @param _tUserLimit total users that can join created tournament.
     * @param _tournamentDurationTime duration time of created tournament. duration time start after starting tournament.
     * Note: emit evente on succesfully tournament creation.
     */

    function createTournament(uint _tUserLimit, uint256 _tournamentDurationTime)
        external
        onleyAdmin
    {
        require(_tUserLimit > 0, "User Limit Can Not Be Zero");
        require(
            _tournamentDurationTime >= 1,
            "Tournament Duration Can Not Zero"
        );
        ++totalTournaments;
        tournamentsList[totalTournaments].isCreated = true;
        tournamentsList[totalTournaments].totalUserLimit = _tUserLimit;
        tournamentsList[totalTournaments]
            .tournamentDurationTime = _tournamentDurationTime;

        emit tournamentStarted(
            totalTournaments,
            block.timestamp,
            _tournamentDurationTime
        );
    }

    /**
     * @dev participants can join tournament using created tournament number.
     * @param _tNumber tournament number.
     * @return bool success or failure status.
     */

    function joinTournament(uint256 _tNumber) external payable returns (bool) {
        require(
            tournamentsList[_tNumber].isCreated,
            "Tournament Does Not Exist"
        );
        require(
            tournamentsList[_tNumber].participants.length <
                tournamentsList[_tNumber].totalUserLimit,
            "Tournament User Limit Reached"
        );
        require(
            msg.value == 2 ether,
            "For Join Touranament User Must Stack 2 Matic"
        );
        require(msg.sender != admin, "Admin Can Not Join Tournament");
        tournamentsList[_tNumber].participants.push(msg.sender);
        return true;
    }

    /**
     * @dev Admin can start tournament once user limit is reached.
     * @param _tNum Tournament number.
     * @return success or failure status.
     */

    function startTournament(uint256 _tNum) external onleyAdmin returns (bool) {
        require(
            tournamentsList[_tNum].participants.length ==
                tournamentsList[_tNum].totalUserLimit,
            "User Limit Not Reached"
        );
        require(
            !tournamentsList[_tNum].isStarted,
            "Tournament Allready Started"
        );
        tournamentsList[_tNum].isStarted = true;
        tournamentsList[_tNum].tournamentStartTime = block.timestamp;
        return true;
    }

    /**
     * @dev Admin can end tournament after tournament duration time is completed.
     * @param _tNum Tournament number.
     * @param _winner Tournament winner address.
     * @return success or failure status.
     */

    function endTournament(uint256 _tNum, address _winner)
        external
        onleyAdmin
        returns (bool)
    {
        require(
            block.timestamp + 2 >
                tournamentsList[_tNum].tournamentStartTime +
                    tournamentsList[_tNum].tournamentDurationTime,
            "Tournament Duration Time Is Not Over At"
        );
        require(
            tournamentsList[_tNum].isStarted,
            "Tournament Does Not Started"
        );
        require(!tournamentsList[_tNum].isEnded, "Tournament Allready Ended");
        bool isWinnerFound;

        tournamentsList[_tNum].isEnded = true;
        for (uint i = 0; i < tournamentsList[_tNum].totalUserLimit; i++) {
            if (tournamentsList[_tNum].participants[i] == _winner) {
                payable(_winner).transfer(
                    2 ether * tournamentsList[_tNum].totalUserLimit
                );
                isWinnerFound = true;
                return true;
            }
        }
        require(!isWinnerFound, "Winner Is Not An Tournament Participent");
        return false;
    }

    /**
     * @dev return total number of tournaments are created.
     */

    function getTotalNumberOfTournaments() external view returns (uint) {
        return totalTournaments;
    }

    /**
     * @dev provide created tournament data based on tournament number.
     * @param _tnumber tournament number.
     */

    function getTournamentsData(uint _tnumber)
        external
        view
        returns (
            bool,
            bool,
            bool,
            uint,
            uint256,
            uint256,
            address[] memory
        )
    {
        return (
            tournamentsList[_tnumber].isCreated,
            tournamentsList[_tnumber].isStarted,
            tournamentsList[_tnumber].isEnded,
            tournamentsList[_tnumber].totalUserLimit,
            tournamentsList[_tnumber].tournamentStartTime,
            tournamentsList[_tnumber].tournamentDurationTime,
            tournamentsList[_tnumber].participants
        );
    }
}
