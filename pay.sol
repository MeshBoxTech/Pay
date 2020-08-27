pragma solidity >=0.5.0 <=0.5.3;


contract Owned {

    /// `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    constructor() public {
        owner = msg.sender;
    }

    address newOwner=0x0000000000000000000000000000000000000000;

    event OwnerUpdate(address _prevOwner, address _newOwner);

    ///change the owner
    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /// accept the ownership
    function acceptOwnership() public{
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0000000000000000000000000000000000000000;
    }
}


contract pay is Owned {
    
    event Transfer(
        address indexed to,
        address indexed from,
        uint256 value,
        bytes32 mac,
        uint256 time,
        uint16 order_type,
        bytes30 order_info
    );
    
    // 盒子列表
    address[] boxList;

    // 盒子状态
    mapping(address=>bool) boxMap;

    // 转账到指定地址
    function transfer(address payable _addr, bytes32 mac, uint16 order_type, bytes30 order_info) public payable {

        assert(boxMap[_addr]);

        require(msg.value > 0);

        _addr.transfer(msg.value);
        
        emit Transfer(_addr, msg.sender, msg.value, mac, now, order_type, order_info);
    }

    // 更改盒子状态
    function changeState(address _addr, bool state) private {
    	
    	// 从列表移除
        if(boxMap[_addr] == true && state == false)
        {
            // 从列表中删除地址
            uint len = boxList.length;
            for(uint i = 0; i < len; i++)
            {
                if (boxList[i] == _addr)
                {
                    // 直接移动末尾元素到被删除元素的位置
                    boxList[i] = boxList[len - 1];
                    boxList.length--;
                    break;
                }
            }

        } else if (boxMap[_addr] == false && state == true)
        {
            // 加入到列表
            boxList.push(_addr);
        }

        boxMap[_addr] = state;
    }
    
    
    // 设置盒子状态
    function setBox(address _addr, bool state) public onlyOwner() {

        changeState(_addr, state);
    }

	// 批量设置盒子状态
    function setBoxBatch(address[] memory _addr, bool[] memory state ) public onlyOwner() {
    	
    	uint len = _addr.length;
    	require (len == state.length);

    	for(uint i = 0; i < len; i++)
    	{
    		changeState(_addr[i], state[i]);
    	}
    }
    
    // 获取盒子状态
    function getState(address _addr) public view returns(bool) {
        return boxMap[_addr];
    }

    // 获取地址列表
    function getList() public view returns(address[] memory) {
        return boxList;
    }
}