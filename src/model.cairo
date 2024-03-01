use starknet::ContractAddress;

#[derive(Drop, Debug, starknet::Store)]
pub struct Game{
    name: felt252,
    desc: felt252,
    company: felt252,
    gold_id: u256,
    gold_name: felt252,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct Item{
    id: u256,
    name: felt252,
    desc: felt252,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct Sell{
    id: u256,
    sell_addr: ContractAddress,
    name: felt252,
    symbol: felt252,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct Buy{
    id: u256,
    sell_addr: ContractAddress,
    name: felt252,
    symbol: felt252
}



