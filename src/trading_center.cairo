use starknet::ContractAddress;

#[starknet::contract]
mod  GameItemTradingCenter{

    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::integer::BoundedInt;
    use starknet::contract_address_const;
    use tradingcenter::model::{Game,Item,Sell,Buy};
    use tradingcenter::abi::IGameItemTradingCenter;

    #[storage]
    struct Storage {
        
        _log_index: u256,
        _name: felt252,
        _games: LegacyMap::<ContractAddress,Game>,
    }

    #[event]
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    enum Event {
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self._log_index.write(0_u256);
        self._name.write('GOLD');
    }

    #[abi(embed_v0)]
    impl GameItemTradingCenterImpl of IGameItemTradingCenter<ContractState>{
        // 游戏元数据管理
        fn gameSingup(ref self: ContractState, game: Game ){
            let caller = get_caller_address();
            if self._games.read(caller){
                // error
            }
            self._games.write(caller, game);
        }
        fn gameUpdate(self: @ContractState){

        }
        fn addItem(self: @ContractState, item: item);
        fn updateItem(self: @ContractState, item: item);

        // 寄售管理
        fn consignment(self: @ContractState);
        fn buy(self: @ContractState);
        fn consignmentOrders(self: @ContractState);

        fn wantToBuy(self: @ContractState);
        fn sell(self: @ContractState);
        fn wantToBuyOrders(self: @ContractState);

        // 拍卖管理
        fn auction(self: @ContractState);
        fn bid(self: @ContractState);
        fn bids(self: @ContractState);
        fn grab(self: @ContractState);

        // 个人管理
        fn mySell(self: @ContractState);
        fn myBuy(self: @ContractState);
        fn myBid(self: @ContractState);
    }

    // 私有方法
    #[generate_trait]
    impl Private of PrivateTrait {
        
    }


}
