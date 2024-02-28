use starknet::ContractAddress;

#[starknet::interface]
pub trait IGameItemTradingCenter<TContractState> {
    fn gameSingup(self: @TContractState);
    fn gameUpdate(self: @TContractState);
    
}

#[starknet::contract]
mod  GameItemTradingCenter{

    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::integer::BoundedInt;
    use starknet::contract_address_const;

    #[storage]
    struct Storage {
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
