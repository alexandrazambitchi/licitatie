pragma solidity ^0.5.0;
// pragma solidity >=0.7.0 <0.9.0;

/**
 * The AuctionHouse
 contract does this and that...
 */

contract AuctionHouse {
	string public name;
    address payable public owner;
	uint public productCount = 0;
    uint public auctionCount = 0;
    uint public activeAuctionCount = 0;
	mapping(uint => Product) public products;
    mapping(uint => Auction) public auctionList;

	struct Product{
        uint id_product;
        string name;
        uint price;
        string artist_name;
        string category;
        string description;
        string image_hash;
        bool purchased;
        bool auction_started;
        bool auction_ended;
    }

    struct Auction{
        uint id_auction;
        uint auctionEndTime;
        address highestBidder;
        uint highestBid;
        uint offerCount;
        bool ended;
        uint id_product;
        mapping(address => uint) clients;
    }

    event ProductCreated(
        uint id_product,
        string name,
        uint price,
        string artist_name,
        string category,
        string description,
        string image_hash,
        bool purchased,
        bool auction_started
    );

    event ProductSold(
        uint id_product,
        string name,
        uint price,
        string artist_name,
        string category,
        string description,
        string image_hash,
        bool purchased,
        bool auction_ended
    );

    event AuctionCreated(
        uint id_auction,
        uint auctionEndTime,
        address highestBidder,
        uint highestBid,
        uint offerCount,
        bool ended,
        uint id_product
    );

    event AuctionUpdated(
        uint id_auction,
        uint auctionEndTime,
        address highestBidder,
        uint highestBid,
        uint offerCount,
        bool ended,
        uint id_product
    );

    event HighestBidIncreased(
        address bidder, 
        uint amount
    );

    event AuctionEnded(
        address winner, 
        uint amount
    );
    

	constructor() public {
		name = "Auction House of Art";
        owner = msg.sender;
	}

	function createProduct (string memory _name, uint _price, string memory _artist, string memory _category, string memory _description, string memory _imageHash) public {
		require(msg.sender == owner);
        require(bytes(_name).length > 0);
        require(_price > 0);
        require(bytes(_artist).length > 0);
        require(bytes(_category).length > 0);
        require(bytes(_description).length > 0);
        require(bytes(_imageHash).length > 0);
		productCount++;
        products[productCount] = Product(productCount, _name, _price, _artist, _category, _description, _imageHash, false, false, false);
		emit ProductCreated(productCount, _name, _price, _artist, _category, _description, _imageHash, false, false);
	}

    function createAuction (uint _id) public {
        Product storage _product = products[_id];
        require(_product.id_product > 0 && _product.id_product <= productCount);
        require(msg.sender == owner);
        _product.auction_started = true;
        products[_id] = _product;
        auctionCount++;
        activeAuctionCount++;
        uint endTime = now + 1 hours;
        auctionList[auctionCount] = Auction(auctionCount, endTime, address(0), _product.price, 0, false, _product.id_product);
        emit AuctionCreated(auctionCount, endTime, address(0), _product.price, 0, false, _product.id_product);
    }

    function bid(uint auction_id, uint bid_value, uint product_id) public payable {
        Product storage _product = products[product_id];
        require(_product.id_product > 0 && _product.id_product <= productCount, "Product not found");
        Auction storage _auction = auctionList[auction_id];
        require(_auction.id_auction > 0 && _auction.id_auction <= auctionCount, "Auction not found");
        require(block.timestamp <= _auction.auctionEndTime, "Auction ended");
        require(bid_value > _auction.highestBid, "Value too little");
        require(msg.sender != owner, "Owner!!!");
        if (_auction.highestBid != _product.price){
            _auction.clients[_auction.highestBidder] = _auction.highestBid;
        }
        _auction.offerCount += 1;
        _auction.highestBidder = msg.sender;
        _auction.highestBid = bid_value;
        // _auction.clientNames[_auction.highestBidder] = clientName;
        auctionList[auction_id] = _auction;
        emit AuctionUpdated(auction_id, _auction.auctionEndTime, msg.sender, bid_value, _auction.offerCount, _auction.ended, product_id);
        emit HighestBidIncreased(msg.sender, bid_value);
    }

    function deleteProduct(uint _id_product) public {
        Product storage _product = products[_id_product];
        require(_product.id_product > 0 && _product.id_product <= productCount, "Product not found");
        _product.purchased = true;
        _product.auction_ended = true;
        products[_id_product] = _product;
        emit ProductSold(_product.id_product, _product.name, _product.price, _product.artist_name, _product.category, _product.description, _product.image_hash, _product.purchased, _product.auction_ended);
    }

    function auctionEnd(uint _id_auction) public {
        Auction storage _auction = auctionList[_id_auction];
        require(_auction.id_auction > 0 && _auction.id_auction <= auctionCount);
        activeAuctionCount--;

        require(block.timestamp >= _auction.auctionEndTime, "Auction not yet ended.");
        require(!_auction.ended, "auctionEnd has already been called.");

        Product storage _product = products[_auction.id_product];
        require(_product.id_product > 0 && _product.id_product <= productCount);
        require(!_product.purchased);

        if(_auction.offerCount==0){
            _product.purchased = false;
        }
        else{
            _product.purchased = true;
        }
        
        _auction.ended = true;
        auctionList[_id_auction] = _auction;

        _product.auction_ended = true;
        products[_auction.id_product] = _product;

        require (_auction.highestBidder != address(0), "No one bid at this auction");

        emit AuctionEnded(_auction.highestBidder, _auction.highestBid);
        emit ProductSold(_product.id_product, _product.name, _product.price, _product.artist_name, _product.category, _product.description, _product.image_hash, _product.purchased, _product.auction_ended);

        if(_auction.highestBidder != owner)
            owner.transfer(_auction.highestBid);
    }
    
    
}
