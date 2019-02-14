pragma solidity ^0.5.1;

contract Database
{
   //adding New user to Database
   struct Members {
       string FirstName;
       string LastName;
       uint RepBalance;
    }

   //assign adress to each member and put an array of member accounts
   //allows look up a specific instructor with their Ethereum address
   mapping (address => Members) members;
   address[] public MemberAccts;

   //Adding a new member with an initial Reputation_Token balance 0
   //Mapp the public key of the sender account (the account who registers) to its corresponding struct Members
   //Add it to the last place in the overall MemberAccts array
    function setMember (string memory _FirstName, string memory _LastName) public {
       Members memory member = members[msg.sender];
       member.RepBalance = 0;

       member.FirstName = _FirstName;
       member.LastName =_LastName;

       MemberAccts.push(msg.sender) -1;
   }

   // Get members which are registered
   function getMembers() view public returns (address[] memory) {
       return MemberAccts;
   }

   //Get the balance of Reputation_Tokens for a specific address
   function getReputationTokenOfMember(address _ETHaddress) view public returns (uint256) {
       return members[_ETHaddress].RepBalance;
   }

   //Count total members on platform
   function countMembers() view public returns (uint) {
       return MemberAccts.length;
   }
   
   
    function getAddress() view public returns (address) {
        return msg.sender;
    }

   //Setting the variables for the request of images
   //@param nameOfTag Tag of the picture that is requested
   //@param aximumNumberOfImages Number of pictures needed
   //@param remainingNumberOfImages how many pictures are left till completion
   //@param perImagePrice Price which will be paid per accepted image
   //@param idOfRequestedDatabase Every Requested Database gets an ID assigned to track it later on
   //@param db Hash array of accepted images for given request
   //@param completed is set to 1 if request is done
   struct RequestedDatabase {
       string nameOfTag;
       uint maximumNumberOfImages;
       uint remainingNumberOfImages;
       uint perImagePrice;
       uint idOfRequestedDatabase;
       uint[] db;
       address ownerOfDatabase;
       bool completed;
   }

//The uploader proposes an image to the request which then needs to be verified
//@param idOfImageProposal unique id of the uploaded image
//@param hashOfImageProposal IPFS address of uploaded picture
//@param tagIdOfProposal is same as idOfRequestedDatabase (above) if the proposed image is voted correct
//@param uploaderAdress Address of uploaded image
//@param votersForCorrect array of all voters who voted for the proposed image fitting the requested pictures
//@param votersForWrong array of all voters who voted that the uploaded picture does not fit the request
//@param countCorrect #of answers for correct
//@param countFalse #of answers for false
//@param numberOfReceiversLeft for future development
//@param numberOfTotalReceivers for future develpment
   struct ImageProposal{
       uint idOfImageProposal;
       uint hashOfImageProposal;
       uint tagIdOfProposal;
       address payable uploaderAdress;
       address[] receiverAddresses;
       address payable[] votersForCorrect;
       address[] votersForWrong;
       uint countCorrect;
       uint countFalse;
       uint numberOfReceiversLeft;
       uint numberOfTotalReceivers;
       }

  //Events fired when NewRequestIsDone & NewImageIsUploaded
   event NewRequestIsDone(string nameOfTag, uint idOfRequestedDatabase, uint perImagePrice);
   event NewImageIsUploaded(uint hashOfImageProposal, uint idOfProposedTag);

  //not used yet
   mapping (uint => address ) private databaseIdToOwnerOfDatabase;

  //@param currentProposedImageIndex index pointer to current image proposal
  //Set up arrays for requests and image proposals
   uint public currentProposedImageIndex = 0;
   RequestedDatabase[] public requests;
   ImageProposal[] public proposedImages;

   //Get the balance of the smart contract
   function getBalance() public view returns (uint256) {
       return address(this).balance;
   }

   //Create new image Database request with the tag which describes the needed Dataset and the amlunt of pictures needed
   function createNewDatabaseRequest(string memory _name, uint _size) payable public {

       //Deposit a payment in ether which is later distributed upon completion to the uploader and voters
       uint _ETHPerImg = (10**15);
       require(msg.value == _ETHPerImg*_size);

       RequestedDatabase memory request;
       request.nameOfTag = _name;
       request.maximumNumberOfImages = _size;
       request.remainingNumberOfImages = _size;
       request.perImagePrice = _ETHPerImg; //there is no double so coins must have soo many zeros
       request.ownerOfDatabase = msg.sender;
       request.completed = false;
       uint a = requests.push(request) - 1 ;
       requests[a].idOfRequestedDatabase = a;
       databaseIdToOwnerOfDatabase[request.idOfRequestedDatabase] = msg.sender;

       //emit the NewRequestIsDone event
       emit NewRequestIsDone(_name, request.idOfRequestedDatabase, request.perImagePrice);
   }

   //Returns current tags which are outstanding waiting for completion 
   //Tag string is in same order of adding therefore ordering is important.
   function getNameOfAvailableTags() public view returns(string memory currentTags, uint[] memory currentTagIds){
       uint currentLength = requests.length;
       uint reducedLength = 0;
       
       //string memory currentTags;
       for(uint ii= 0 ; ii < currentLength; ii++){
           if(!requests[ii].completed){
               string memory currentString = string(abi.encodePacked(requests[ii].nameOfTag , string(","))) ;
               currentTags = string(abi.encodePacked(currentTags, currentString));
               reducedLength++;
           }
       }
       uint curInd = 0;
       currentTagIds  = new uint[](reducedLength);
       for(uint ii= 0; ii < currentLength; ii++){
           if(!requests[ii].completed){
               currentTagIds[curInd] = requests[ii].idOfRequestedDatabase;
               curInd++;
           }
       }        
   }

   //handles the upload of Image Proposal
   function uploadImageProposal(uint _hash, uint _idOfProposedTag) public {

       //find the database Id i.e tagId of the proposed tag name chosen from the getNameOfAvailableTags function
       //uint currentLength = requests.length;
       //uint idOfProposedTag = currentLength;
       //for(uint ii; ii < currentLength; ii++){
       //   if(!requests[ii].completed){
       //        string memory s1 = _proposedTagName;
       //        string memory s2 = requests[ii].nameOfTag;
       //        if(keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))){
       //            idOfProposedTag = requests[ii].;
       //        }
       //    }
       //}        
       
       ImageProposal memory proposedImage;
       proposedImage.hashOfImageProposal = _hash;
       proposedImage.tagIdOfProposal = _idOfProposedTag;
       proposedImage.uploaderAdress = msg.sender;
       proposedImage.numberOfTotalReceivers = 3;
       proposedImage.numberOfReceiversLeft = proposedImage.numberOfTotalReceivers; //It is value of receivers that judges
       uint a = proposedImages.push(proposedImage)-1;
       proposedImages[a].idOfImageProposal = a;
       proposedImage.countFalse = 0;
       proposedImage.countCorrect = 0;
       emit NewImageIsUploaded(proposedImage.hashOfImageProposal, proposedImage.tagIdOfProposal);

   }

   //when called it selects an uploaded image starting from
   function retrieveAnImageFromProposal() public returns(uint hashImage, string memory tagName){

       require(proposedImages[currentProposedImageIndex].numberOfReceiversLeft > 0);
       //check whether the sender is the uploader of next image or not
       require(msg.sender != proposedImages[currentProposedImageIndex].uploaderAdress);
       // check whether this address is already voted or downloaded the image before

       //Check the proposed Tag Id so that it is for a incomplete database.

       //add this address to receivers
       proposedImages[currentProposedImageIndex].receiverAddresses.push(msg.sender);
       hashImage = proposedImages[currentProposedImageIndex].hashOfImageProposal;
       tagName = requests[proposedImages[currentProposedImageIndex].tagIdOfProposal].nameOfTag;
   }

   //vote for an image whether the uploaded image fits to the requested tag
   function voteForImage(uint vote) public {

       //check whether receiverAddresses is not empty
       require(proposedImages[currentProposedImageIndex].numberOfReceiversLeft > 0);
       require(msg.sender != proposedImages[currentProposedImageIndex].uploaderAdress);
       // check whether messenger address is in the list of image receivers
       uint len = proposedImages[currentProposedImageIndex].receiverAddresses.length;
       bool existenceInReceiverSide = false;
       for(uint ii = 0; ii<len; ii++){
           existenceInReceiverSide = proposedImages[currentProposedImageIndex].receiverAddresses[ii]== msg.sender;
           if(existenceInReceiverSide== true){
               break;
           }
       }
       require(existenceInReceiverSide);
       
       //decrease the numberOfReceiversLeft
       proposedImages[currentProposedImageIndex].numberOfReceiversLeft--;
       
       if(vote == 1 ){ 
           //vote is assigned as correct
           proposedImages[currentProposedImageIndex].votersForCorrect.push(msg.sender);
           proposedImages[currentProposedImageIndex].countCorrect++;
       }
       else if(vote == 0){ 
           //vote is assigned as incorrect
           proposedImages[currentProposedImageIndex].votersForWrong.push(msg.sender);
           proposedImages[currentProposedImageIndex].countFalse++;
       }

       //Threshold until uploaded image counts as correct
       uint thresholdCorrect = proposedImages[currentProposedImageIndex].numberOfTotalReceivers / 2 + 1;
       uint thresholdFalse = proposedImages[currentProposedImageIndex].numberOfTotalReceivers - thresholdCorrect + 1 ;
       
       //Check for the correctness of the vote
       if(proposedImages[currentProposedImageIndex].countCorrect >= thresholdCorrect){
           //Add the proposedImage to the database corresponds to idOfProposedTag
           addCurrentImageToDatabase();

          address payable[] storage participants = proposedImages[currentProposedImageIndex].votersForCorrect;

          //anyone who voted right is put into a list
          participants.push(proposedImages[currentProposedImageIndex].uploaderAdress);

          //Reward everyone in this list with a reputation token and ether.
          for (uint i =0; i < participants.length; i++){
                  members[participants[i]].RepBalance++;
                  participants[i].transfer((10**15)/participants.length);
              }

          //deduct one reputation token for a false answer
          address[] memory participantsWrong = proposedImages[currentProposedImageIndex].votersForWrong;

          for( uint i=0; i< participantsWrong.length ; i++){
                  if(members[participantsWrong[i]].RepBalance >0)
                      members[participantsWrong[i]].RepBalance--;
              }

          //do the transaction to the vote for the correct receivers and uploader.

          deleteCurrentProposedImage();
       
       }else if(proposedImages[currentProposedImageIndex].countFalse >= thresholdFalse){
           
           //Discard the proposedImage as a false data and ignore it
           deleteCurrentProposedImage();
            
            address[] memory participants = proposedImages[currentProposedImageIndex].votersForWrong;
           //anyone who voted right + the uploader is rewarded
           
           //reward everyone in this list with a reputation token and ether.
           for (uint i =0; i < participants.length; i++){
               members[participants[i]].RepBalance++;
           }

           //deduct one reputation token for a false answer
           address payable[] storage participantsWrong = proposedImages[currentProposedImageIndex].votersForCorrect;
            participantsWrong.push(proposedImages[currentProposedImageIndex].uploaderAdress);

           for( uint i=0; i< participantsWrong.length ; i++){
               if(members[participantsWrong[i]].RepBalance >0)
                   members[participantsWrong[i]].RepBalance--;
           }
           
       }
   }

   //After True voting, the image is added to the database
   function addCurrentImageToDatabase() private{
       uint tagId = proposedImages[currentProposedImageIndex].tagIdOfProposal;
       uint imgAddress = proposedImages[currentProposedImageIndex].hashOfImageProposal;  

       //check the number of remaining number of images
       require(requests[tagId].remainingNumberOfImages > 0);

       //add the image to the corresponding database
       requests[tagId].db.push(imgAddress);
       requests[tagId].remainingNumberOfImages--;

       //if the task is complete the database is removed from the visible tags
       //emits database complete signal
       //makes the database obtainable by the user
       if(requests[tagId].remainingNumberOfImages == 0 ){
           requests[tagId].completed=true;
       }
   }
   function deleteCurrentProposedImage() private{
       currentProposedImageIndex++;
       //if (currentProposedImageIndex >= proposedImages.length){
       //    deleteAllProposedImages();
       //}
   }
}
   //function deleteAllProposedImages() private{
   //    currentProposedImageIndex = 0;
   //    proposedImages = newArray;
   //}

