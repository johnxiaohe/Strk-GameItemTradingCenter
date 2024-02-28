use starknet::ContractAddress;

#[derive(Drop, Debug, starknet::Store)]
pub struct game{
    name: felt252,
    desc: felt252,
    company: felt252,
    gold_id: u256,
    gold_name: felt252,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct item{
    id: u256,
    name: felt252,
    desc: felt252,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct sell{
    id: u256,
    sell_addr: ContractAddress,
    name: felt252,
    symbol: felt252
}

#[derive(Drop, Debug, starknet::Store)]
pub struct buy{
    id: u256,
    sell_addr: ContractAddress,
    name: felt252,
    symbol: felt252
}



