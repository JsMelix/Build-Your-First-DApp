// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract StackUpQuests {
    address public admin;
    
    struct Quest {
        string description;
        uint reward;
        bool approved;
        bool completed;
        uint startTime;
        uint endTime;
    }
    
    mapping(uint => Quest) public quests;
    uint public questCount;
    
    event QuestAdded(uint questId, string description, uint reward);
    event QuestReviewed(uint questId, bool approved);
    event QuestCompleted(uint questId);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        questCount = 0;
    }
    
    // Function to add a new quest
    function addQuest(string memory _description, uint _reward, uint _startTime, uint _endTime) public onlyAdmin {
        uint questId = questCount++;
        quests[questId] = Quest(_description, _reward, false, false, _startTime, _endTime);
        emit QuestAdded(questId, _description, _reward);
    }
    
    // Function to review a quest and approve or reject it
    function reviewQuest(uint _questId, bool _approved) public onlyAdmin {
        Quest storage quest = quests[_questId];
        require(!quest.completed, "Quest already completed");
        require(quest.startTime > block.timestamp, "Quest has already started or ended");
        
        quest.approved = _approved;
        emit QuestReviewed(_questId, _approved);
    }
    
    // Function for users to complete a quest and claim the reward
    function completeQuest(uint _questId) public {
        Quest storage quest = quests[_questId];
        require(!quest.completed, "Quest already completed");
        require(quest.approved, "Quest not approved yet");
        require(quest.startTime <= block.timestamp && block.timestamp <= quest.endTime, "Quest not currently active");
        
        quest.completed = true;
        emit QuestCompleted(_questId);
        
        // Transfer the reward to the user who completed the quest
        payable(msg.sender).transfer(quest.reward);
    }
}
