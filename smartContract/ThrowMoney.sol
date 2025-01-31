// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


//ERC20規格を読み込むための準備
interface IERC20 {
    //標準的なインタフェース
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // 追加で呼び出したい関数を指定
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}

// 投げ銭のスマコン
contract ThrowMoney {

    //上で定義した ERC20 規格を呼び出すためのインタフェース
    IERC20 public jpyc;

    event ErrorLog(string _error_message);
    event MoneySent(address indexed __senderAddr, address indexed __reciveAddr, string __message, string __alias, uint __amount);

    constructor() {
        // Rinkeby Network の JPYC
        jpyc = IERC20(0xbD9c419003A36F187DAf1273FCe184e1341362C0);
    }

    // トークン名を確認する関数
    function getname() public view returns (string memory){
        return jpyc.name();
    }

    // シンボル (JPYC) を確認する関数
    function getsymbol() public view returns (string memory){
        return jpyc.symbol();
    }

    // プールに入っている金額を確認する関数
    function jpycAmount() public view returns (uint) {
        return jpyc.balanceOf(address(this)) / 10 ** 18;
    }

    // プールからの送金を許可する関数
    function approveJpycFromContract() public {
        jpyc.approve(address(this) , jpyc.balanceOf(address(this)) );
    }

    // コントラストから配信者へ送金する関数
    function sendJpyc(address _reciveAddr,
                       string memory _message,
                       string memory _senderAlias,
                       uint _amount) public {

        // 換算
        uint _amount_wei = _amount * 10 ** 18;

        // 送金額がプールされて金額以下となるようにチェック
        require(jpyc.balanceOf(address(this)) >= _amount);

        // 送金に必要なデータが登録されているかをチェック
        require(bytes(_message).length != 0);
        require(_amount != 0);
        require(_reciveAddr != address(0));

        // プールからの送金を許可
        jpyc.approve(address(this), _amount_wei);

        try jpyc.transferFrom(address(this), _reciveAddr, _amount_wei) {
            // 送金成功時にイベントを発出
            emit MoneySent(msg.sender, _reciveAddr, _message, _senderAlias, _amount);
        } catch {
            // 送金失敗時にはエラーを発出
            emit ErrorLog("Error When Sending Money");
        }
        
    }
}