use core::option::OptionTrait;
use core::traits::TryInto;
use core::result::ResultTrait;
use core::array::SpanTrait;
use core::array::ArrayTrait;
use tradingcenter::erc20::ERC20;
use tradingcenter::erc20::IERC20Dispatcher;
use tradingcenter::erc20::IERC20DispatcherTrait;
use tradingcenter::erc20::ERC20::{Event, Transfer, Approval};

use starknet::deploy_syscall;
use starknet::ContractAddress;
use starknet::contract_address_const;
// 测试包，用于修改交易信息等作弊手段
use starknet::testing::set_contract_address;
use starknet::testing::pop_log;
use core::test::test_utils::assert_eq;

const NAME: felt252 = 'TEST';
const SYMBOL: felt252 = 'TEST';
const DECIMALS: u8 = 18_u8;

#[test]
fn test_initializer(){
    let mut calldata = array![NAME, SYMBOL, DECIMALS.into()];
    let (erc20_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(),
        0,
        calldata.span(),
        false
    ).unwrap();

    let erc20_token = IERC20Dispatcher{contract_address: erc20_address};
    assert_eq(@erc20_token.name(), @NAME, 'NAME ERR');
    assert_eq(@erc20_token.symbol(), @SYMBOL, 'SYMBOL ERR');
    assert_eq(@erc20_token.decimals(), @DECIMALS, 'Decimals ERR');
}

fn set_up() -> (ContractAddress, IERC20Dispatcher, ContractAddress){
    // 设置合约API调用方(测试用例合约)的合约地址固定为 1 
    let caller = contract_address_const::<1>();
    set_contract_address(caller);

    let mut calldata = array![NAME, SYMBOL, DECIMALS.into()];

    let (erc20_address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(),
        0,
        calldata.span(),
        false
    ).unwrap();

    let mut erc20_token = IERC20Dispatcher{ contract_address: erc20_address };

    (caller, erc20_token, erc20_address)
}

#[test]
fn test_approve(){
    let (caller, erc20_token, erc20_address) = set_up();
    let spender = contract_address_const::<2>();
    let amount = 2000_u256;

    erc20_token.approve(spender, amount);
    assert_eq(@erc20_token.allowance(caller,spender), @amount, 'Approval not eq 2000');
    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Approval(Approval{owner: caller, spender, value: amount}), 'Approval event not Emit');
}

#[test]
fn test_mint(){
    let (caller, erc20_token, erc20_address) = set_up();
    let amount = 2000_u256;
    erc20_token.mint(amount);
    assert_eq(@erc20_token.blanceOf(caller), @amount, 'Mint 2000');
    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Transfer(Transfer{from: caller, to: caller, value: amount}), 'Transfer not Emit');
}

#[test]
fn test_transfer(){
    let (from, erc20_token, erc20_address) = set_up();
    let amount = 2000_u256;
    let to = contract_address_const::<2>();

    erc20_token.mint(amount);
    erc20_token.transfer(to, amount);

    assert_eq(@erc20_token.blanceOf(to), @amount, 'Blance 2000');
    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Transfer(Transfer{from: from, to: to, value: amount}), 'Transfer not Emit');
}

#[test]
#[should_panic(expected: ('u256_sub Overflow', 'ENTRYPOINT_FAILED'))]
fn test_err_transfer(){
    let (from, erc20_token, erc20_address) = set_up();
    let amount = 2000_u256;
    let to = contract_address_const::<2>();

    erc20_token.mint(amount);
    erc20_token.transfer(to, 3000_u256);

    assert_eq(@erc20_token.blanceOf(to), @amount, 'Blance 2000');
    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Transfer(Transfer{from: from, to: to, value: amount}), 'Transfer not Emit');
}

#[test]
fn test_transferFrom(){
    let (from, erc20_token, erc20_address) = set_up();
    let amount = 2000_u256;

    let caller = contract_address_const::<2>();
    let to = contract_address_const::<3>();
    erc20_token.mint(amount);
    erc20_token.approve(caller, amount);

    set_contract_address(caller);

    erc20_token.transferFrom(from, to, 1000_u256);

    assert_eq(@erc20_token.blanceOf(from), @1000_u256, 'err');
    assert_eq(@erc20_token.blanceOf(to), @1000_u256, 'err');

    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Transfer(Transfer{from: from, to: from, value: amount}), 'Transfer not Emit');
    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Approval(Approval{owner: from, spender: caller, value: amount}), 'Approval not Emit');
    assert_eq(@pop_log(erc20_address).unwrap(), @Event::Transfer(Transfer{from: from, to: to, value: 1000_u256}), 'Transfer not Emit');
}




