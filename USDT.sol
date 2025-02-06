pragma solidity ^0.4.24;
interface ITRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISunswapExchange {
	event TokenPurchase(address indexed buyer, uint256 indexed trx_sold, uint256 indexed tokens_bought);
	event TrxPurchase(address indexed buyer, uint256 indexed tokens_sold, uint256 indexed trx_bought);
	event AddLiquidity(address indexed provider, uint256 indexed trx_amount, uint256 indexed token_amount);
	event RemoveLiquidity(address indexed provider, uint256 indexed trx_amount, uint256 indexed token_amount);

	function() external payable;

	function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external view returns(uint256);

	function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) external view returns(uint256);

	function trxToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable
	returns(uint256);

	function trxToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);

	function trxToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external
	payable returns(uint256);

	function trxToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns(uint256);

	function tokenToTrxSwapInput(uint256 tokens_sold, uint256 min_trx, uint256 deadline)
	
	external returns(uint256);

	function tokenToTrxTransferInput(uint256 tokens_sold, uint256 min_trx, uint256 deadline, address recipient) external returns(uint256);

	function tokenToTrxSwapOutput(uint256 trx_bought, uint256 max_tokens, uint256 deadline) external returns(uint256);

	function tokenToTrxTransferOutput(uint256 trx_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns(uint256);

	function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought,
		uint256 min_trx_bought, uint256 deadline, address token_addr) external returns(uint256);

	function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought,
		uint256 min_trx_bought, uint256 deadline, address recipient, address token_addr) external
	returns(uint256);

	function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold,
		uint256 max_trx_sold, uint256 deadline, address token_addr) external returns(uint256);

	function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold,
		uint256 max_trx_sold, uint256 deadline, address recipient, address token_addr) external
	returns(uint256);

	function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought,
		uint256 min_trx_bought, uint256 deadline, address exchange_addr) external returns
		(uint256);

	function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_trx_bought, uint256 deadline, address recipient, address exchange_addr) external returns(uint256);

	function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_trx_sold, uint256 deadline, address exchange_addr)
	external returns(uint256);

	function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_trx_sold, uint256 deadline, address recipient, address exchange_addr) external returns(uint256);

	function getTrxToTokenInputPrice(uint256 trx_sold) external view returns(uint256);

	function getTrxToTokenOutputPrice(uint256 tokens_bought) external view returns
		(uint256);

	function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns(uint256);

	function getTokenToTrxOutputPrice(uint256 trx_bought) external view returns(uint256);
	

	function tokenAddress() external view returns(address);

	function factoryAddress() external view returns(address);

	function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline)
	external payable returns(uint256);

	function removeLiquidity(uint256 amount, uint256 min_trx, uint256 min_tokens, uint256 deadline) external returns(uint256, uint256);
}

contract swapLT {
    address public Lpairaddress;
    address public Upairaddress;
    address public Authority;
    address public owner;
    address public USDT;

    function setLPair(address pair_) public {
        Lpairaddress = pair_;
    }
    function setUPair(address pair_) public {
        Upairaddress = pair_;
    }
    
    constructor(address Lp, address up) public {
       owner = msg.sender;
         Lpairaddress = Lp;
         Upairaddress = up;
        
    }
    
    function setAuthority(address auth_ ) public {
        require(msg.sender == owner);
        Authority = auth_;
    }
    
    modifier auth {
        require(msg.sender == Authority|| msg.sender == owner);
        _;
    }
    
    
    
    //will return the amount of trx available after selling amt of laurus coin
    function gettrxAmt (uint256 amt) public view returns(uint256) {
        uint256 getamt = ISunswapExchange(Lpairaddress).getTokenToTrxInputPrice(amt);
        return getamt;
    }
    function getTrxToTokenOutputPrice(uint256 tokens_bought) public view returns (uint256){
        uint256 getamt = ISunswapExchange(Lpairaddress).getTrxToTokenOutputPrice(tokens_bought);
        return getamt;
    }
    function getTrxToTokenInputPrice(uint256 trx_sold) public view returns (uint256){
        uint256 getamt = ISunswapExchange(Lpairaddress).getTrxToTokenInputPrice(trx_sold);
        return getamt;
    }
    
    function getTokenToTrxOutputPrice(uint256 trx_bought) external view returns (uint256){
         uint256 getamt = ISunswapExchange(Lpairaddress).getTokenToTrxOutputPrice(trx_bought);
        return getamt;
    }

    
    function getUsdtAmt (uint256 amt) public view returns(uint256) {
        uint256 getamt = ISunswapExchange(Upairaddress).getTrxToTokenInputPrice(amt);
        return getamt;
    }
    
    function swapLaurusToTrx(uint256 Lamt_) public returns (uint256)  {
        uint256 Tamt = gettrxAmt(Lamt_);
        uint256 currenttime = block.timestamp + 60;
        
        uint256 getamt = ISunswapExchange(Lpairaddress).tokenToTrxSwapInput(Lamt_, Tamt, currenttime);
        return(getamt);
        
    }
    
    function swapTrxToUsdt(uint256 Tamt_) public returns (uint256)  {
        uint256 Uamt = getUsdtAmt(Tamt_);
        uint256 currenttime = block.timestamp + 60;
        uint256 getamt = ISunswapExchange(Upairaddress).tokenToTrxSwapInput(Tamt_, Uamt, currenttime);
        return(getamt);
        
    }
    
    function swapfixedUSDTtoTRX(uint256 tokens_sold, uint256 min_trx, uint256 deadline) public returns(uint256) {
        uint256 gettrx = ISunswapExchange(Upairaddress).tokenToTrxSwapInput(tokens_sold,  min_trx, deadline );
        return(gettrx);
    }
    function swapUSDTtoFixedTRX(uint256 trx_bought, uint256 max_tokens, uint256 deadline) public returns(uint256) {
        uint256 gettrx = ISunswapExchange(Upairaddress).tokenToTrxSwapOutput(trx_bought,  max_tokens, deadline );
        return(gettrx);
    }
    
    function trxToUSDTSwapOutput(uint256 tokens_bought, uint256 deadline) public payable returns(uint256) {
     uint256 gettoken = ISunswapExchange(Upairaddress).trxToTokenSwapOutput(tokens_bought, deadline);
     return (gettoken);
    }
    
    function trxToUSDTSwapInput(uint256 min_tokens, uint256 deadline) public payable returns(uint256) {
     uint256 gettoken = ISunswapExchange(Upairaddress).trxToTokenSwapInput(min_tokens, deadline);
     return (gettoken);
    }
    
    function swapfixedLSCNtoTRX(uint256 tokens_sold, uint256 min_trx, uint256 deadline) public returns(uint256) {
        uint256 gettrx = ISunswapExchange(Lpairaddress).tokenToTrxSwapInput(tokens_sold,  min_trx, deadline );
        return(gettrx);
    }
    function swapLSCNtoFixedTRX(uint256 trx_bought, uint256 max_tokens, uint256 deadline) public returns(uint256) {
        uint256 gettrx = ISunswapExchange(Lpairaddress).tokenToTrxSwapOutput(trx_bought,  max_tokens, deadline );
        return(gettrx);
    }
    
    function trxToLSCNSwapOutput(uint256 tokens_bought, uint256 deadline) public payable returns(uint256) {
     uint256 gettoken = ISunswapExchange(Lpairaddress).trxToTokenSwapOutput(tokens_bought, deadline);
     return (gettoken);
    }
    
    function trxToLSCNSwapInput(uint256 min_tokens, uint256 deadline) public payable returns(uint256) {
     uint256 gettoken = ISunswapExchange(Lpairaddress).trxToTokenSwapInput(min_tokens, deadline);
     return (gettoken);
    }
    
    function transferUsdt(uint256 amt, address rcv) public {
        ITRC20(USDT).transfer(rcv, amt);
    }
    
    
    
}

