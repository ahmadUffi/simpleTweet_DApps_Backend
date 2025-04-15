// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/IProfile.sol";

// interface profile for connection  with TUserProfile



contract Twitter is Ownable{
    IProfile private profileContract;

    // interaction with @openzeppelin
    constructor(address _profileContract) Ownable(msg.sender) {
        profileContract = IProfile(_profileContract);
    }

    // maxTweet
    uint16 public maxTweetLength= 280;


    struct Tweet{
        uint256 id;
        address owner;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Tweet[]) public  tweets;

    // define event
    event tweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event tweetLiked(address liker, address tweetAuhor, uint256 tweetId, uint newLikeTweet);
    event tweetUnLiked(address unliker, address tweetAuhor, uint256 tweetId, uint newLikeTweet);

    // drfine modifier
    modifier tweetExist(address _author, uint256 _id){
        require(tweets[_author][_id].id == _id, "tweet dosent exist");
        _;
    }
    modifier onlyRegistered(){
        IProfile.userProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length > 0, "User Don't Registered yet");
        _;
    }

    function changeTweetLength(uint16 _newTweetLength) public onlyOwner{
        maxTweetLength = _newTweetLength;
    }

    function createTweet( string memory _tweet) public onlyRegistered {
        require(bytes(_tweet).length <= maxTweetLength, "tweet to long my friends, maximum is 280");

        Tweet memory newTweet = Tweet({
            id : tweets[msg.sender].length,
            owner : msg.sender,
            content : _tweet,
            timestamp : block.timestamp,
            likes : 0
        });

        tweets[msg.sender].push(newTweet);

        emit tweetCreated(newTweet.id, newTweet.owner, newTweet.content, newTweet.timestamp);
        
    }


    function likeTweet(address _author, uint256 _id) external tweetExist(_author, _id) onlyRegistered {
        tweets[_author][_id].likes++;
        emit tweetLiked(msg.sender, _author, _id, tweets[_author][_id].likes);
    }

    function unLikeTweet(address _author, uint256 _id) external tweetExist(_author, _id) onlyRegistered{
        require(tweets[_author][_id].likes > 0, "Cannot unlike a tweet that hasn't been liked");
        tweets[_author][_id].likes--;
        emit tweetUnLiked(msg.sender, _author, _id, tweets[_author][_id].likes);
    }

    function getTweet(address _owner, uint256 _i) public view returns (Tweet memory) {
        return tweets[_owner][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
            return tweets[_owner];
    }

    function getAllTotalLikes(address _author) external view returns (uint256) {
        uint totalLikes;

        for(uint i = 0; i < tweets[_author].length; i++){
            if(tweets[_author][i].owner == _author){
                totalLikes += tweets[_author][i].likes;
            }
        }

        return totalLikes; 
    }
}
