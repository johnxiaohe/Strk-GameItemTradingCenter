use starknet::ContractAddress;
use tradingcenter::model::{game,item,sell};

#[starknet::interface]
pub trait IGameItemTradingCenter<TContractState> {
    // 游戏元数据管理
    fn gameSingup(self: @TContractState);
    fn gameUpdate(self: @TContractState);
    fn addItem(self: @TContractState, item: item);
    fn updateItem(self: @TContractState, item: item);

    // 寄售管理
    fn consignment(self: @TContractState);
    fn buy(self: @TContractState);
    fn consignmentOrders(self: @TContractState);

    fn wantToBuy(self: @TContractState);
    fn sell(self: @TContractState);
    fn wantToBuyOrders(self: @TContractState);

    // 拍卖管理
    fn auction(self: @TContractState);
    fn bid(self: @TContractState);
    fn bids(self: @TContractState);
    fn grab(self: @TContractState);

    // 个人管理
    fn mySell(self: @TContractState);
    fn myBuy(self: @TContractState);
    fn myBid(self: @TContractState);
    
}

#[starknet::contract]
mod  GameItemTradingCenter{

    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::integer::BoundedInt;
    use starknet::contract_address_const;
    use tradingcenter::model::{game,item,sell};

    #[storage]
    struct Storage {
        _game_index: u256,
        _log_index: u256,
        _name: felt252,
    }

    #[event]
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    enum Event {
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        
    }

    #[abi(embed_v0)]
    impl GameItemTradingCenterImpl of super::IGameItemTradingCenter<ContractState>{
        
    }

    // 私有方法
    #[generate_trait]
    impl Private of PrivateTrait {
        
    }


}
