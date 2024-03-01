use starknet::ContractAddress;

#[derive(Drop, Debug, starknet::Store, Zero)]
pub struct Game{
    pub name: felt252,
    pub desc: felt252,
    pub company: felt252,
    pub gold_id: u256,
    pub gold_name: felt252,
    pub contract_address: ContractAddress,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct Item{
    pub id: u256,
    pub name: felt252,
    pub desc: ByteArray,
    pub icon: ByteArray,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct Order{
    pub id: u256,
    pub item_id: u256,
    pub owner_addr: ContractAddress,
    pub amount: u256,
    pub leftover: u256,
    pub price: u256,
    pub order_type: felt252,
    pub close: bool,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct OrderLog{
    pub id: u256,
    pub order_id: u256,
    pub op_addr: ContractAddress,
    pub amount: u256,
    pub price: u256,
}

#[derive(Drop, Debug, starknet::Store)]
pub struct Buy{
    pub id: u256,
    pub item_id: u256,
    pub owner_addr: ContractAddress,
    pub amount: u256,
    pub leftover: u256,
    pub price: u256,
}

