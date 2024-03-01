use starknet::ContractAddress;

#[starknet::contract]
mod  GameItemTradingCenter{

    use core::num::traits::zero::Zero;
    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::integer::BoundedInt;
    use starknet::contract_address_const;
    use tradingcenter::model::{Game,Item,Order,OrderLog,Buy};
    use tradingcenter::abi::IGameItemTradingCenter;
    use alexandria_storage::list::List;

    #[storage]
    struct Storage {
        
        _log_index: u256,
        _order_index: u256,
        _name: felt252,
        _games: LegacyMap::<ContractAddress,Game>,
        _items: LegacyMap::<(ContractAddress, u256), Item>,
        // 订单id-订单信息 映射
        _sell_orders: LegacyMap::<u256, Order>,
        _buy_orders: LegacyMap::<u256, Order>,

        // 游戏-道具-订单ID列表 映射 可变
        _item_sell_orders: LegacyMap::<(ContractAddress, u256),List<u256>>,
        _item_buy_orders: LegacyMap::<(ContractAddress, u256),List<u256>>,

        // 游戏-用户-订单ID列表映射(未完成的) 可变
        _user_active_orders: LegacyMap::<(ContractAddress, ContractAddress),List<u256>>,
        // 游戏-用户-订单ID列表映射(已完成的) 不可变
        _user_close_orders: LegacyMap::<(ContractAddress, ContractAddress),Array<u256>>,

        // 游戏-道具订单-订单日志列表 映射 不可变
        _order_logs: LegacyMap::<(ContractAddress, u256),Array<OrderLog>>,
    }

    #[event]
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    enum Event {
        GameSingupError: GameSingupError,
        GameNotExitError: GameNotExitError,
        GameItemError: GameItemError,
        ItemNotExistError: ItemNotExistError,
    }

    // 事件实现
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct GameSingupError{
        // #[key]表示可支持块数据检索的字段
        #[key]
        pub sign_address: ContractAddress,
        pub msg: felt252,
    }

    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct GameNotExitError{
        // #[key]表示可支持块数据检索的字段
        #[key]
        pub game_address: ContractAddress,
        pub call_method: felt252,
    }

    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct GameItemError{
        // #[key]表示可支持块数据检索的字段
        #[key]
        pub game_address: ContractAddress,
        pub call_method: felt252,
        pub msg: felt252,
    }

    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct ItemNotExistError{
        // #[key]表示可支持块数据检索的字段
        #[key]
        pub game_address: ContractAddress,
        pub call_method: felt252,
        pub item_id: u256,
        pub msg: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self._log_index.write(0_u256);
        self._order_index.write(0_u256);
        self._name.write('GOLD');
    }

    #[abi(embed_v0)]
    impl GameItemTradingCenterImpl of IGameItemTradingCenter<ContractState>{
        // 关于abi调用结果确认问题，是通过emit还是回调通信? 回调会产生gas问题会对整个流程成本的增加. 或者是查询链数据,这个是否在链上可以确认?
        
        // 游戏基础信息管理
        fn gameSingup(ref self: ContractState, game: Game ){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_non_zero(){
                self.emit(GameSingupError{sign_address: caller, msg: 'exists, call gameUpdate'});
            }else{
                self._games.write(caller, game);
            }
        }
        fn gameUpdate(ref self: ContractState, game: Game ){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_non_zero(){
                self._games.write(caller, game);
            }else{
                self.emit(GameNotExitError{game_address: caller, call_method: 'gameUpdate'})
            }
        }

        // 游戏道具管理
        fn addItem(ref self: ContractState, item: Item){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                return self.emit(GameNotExitError{game_address: caller, call_method: 'addItem'});
            }
            if item.id == 0_u256 {
                return self.emit(GameItemError{game_address: caller, call_method: 'addItem', msg:'item.id not 0'});
            }
            if self._items.read((caller, item.id)).id > 0_u256{
                return self.emit(GameItemError{game_address: caller, call_method: 'addItem', msg:'item exit'});
            }
            self._items.write((caller, item.id), item);
        }
        fn updateItem(ref self: ContractState, item: Item){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                return self.emit(GameNotExitError{game_address: caller, call_method: 'updateItem'});
            }
            if item.id == 0_u256 {
                return self.emit(GameItemError{game_address: caller, call_method: 'updateItem', msg:'item.id not 0'});
            }
            if self._items.read((caller, item.id)).id == 0_u256{
                return self.emit(ItemNotExistError{game_address: caller, call_method: 'updateItem', item_id: item.id, msg:'item not exit, call addItem'});
            }
            self._items.write((caller, item.id), item);
        }

        // 寄售管理
        fn consignment(ref self: ContractState, itemId: u256, amount: u256, price: u256){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                return self.emit(GameNotExitError{game_address: caller, call_method: 'consignment'});
            }
            if self._items.read((caller, itemId)).id == 0_u256{
                return self.emit(ItemNotExistError{game_address: caller, call_method: 'consignment', item_id: itemId, msg:'item not exit'});
            }
            // 创建订单, 保存游戏-订单、玩家-订单映射
            self._item_sell_orders.write((caller,itemId),)
        }
        fn buy(self: @ContractState){

        }
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
