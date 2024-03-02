use starknet::ContractAddress;

#[starknet::contract]
mod  GameItemTradingCenter{

    use core::option::OptionTrait;
use core::traits::TryInto;
use core::result::ResultTrait;
use core::array::ArrayTrait;
use core::num::traits::zero::Zero;
    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::integer::BoundedInt;
    use starknet::contract_address_const;
    use tradingcenter::model::{Game,Item,Order,OrderLog,Buy};
    use tradingcenter::abi::IGameItemTradingCenter;
    use alexandria_storage::list::{List, ListTrait};

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
        OrderNotExistError: OrderNotExistError,
        OrderError: OrderError,
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
        #[key]
        pub call_method: felt252,
        #[key]
        pub item_id: u256,
        pub msg: felt252,
    }

    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct OrderNotExistError{
        // #[key]表示可支持块数据检索的字段
        #[key]
        pub game_address: ContractAddress,
        #[key]
        pub caller: ContractAddress,
        pub call_method: felt252,
        #[key]
        pub order_id: u256,
        pub msg: felt252,
    }

    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct OrderError{
        // #[key]表示可支持块数据检索的字段
        #[key]
        pub game_address: ContractAddress,
        pub caller: ContractAddress,
        pub call_method: felt252,
        #[key]
        pub order_id: u256,
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
        fn gameSingup(ref self: ContractState, game: Game ) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_non_zero(){
                self.emit(GameSingupError{sign_address: caller, msg: 'exists, call gameUpdate'});
                return false;
            }else{
                self._games.write(caller, game);
                return true;
            }
        }
        fn gameUpdate(ref self: ContractState, game: Game ) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_non_zero(){
                self._games.write(caller, game);
                return true;
            }else{
                self.emit(GameNotExitError{game_address: caller, call_method: 'gameUpdate'})
                return false;
            }
        }

        // 游戏道具管理
        fn addItem(ref self: ContractState, item: Item) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                self.emit(GameNotExitError{game_address: caller, call_method: 'addItem'});
                return false;
            }
            if item.id == 0_u256 {
                self.emit(GameItemError{game_address: caller, call_method: 'addItem', msg:'item.id not 0'});
                return false;
            }
            if self._items.read((caller, item.id)).id > 0_u256{
                self.emit(GameItemError{game_address: caller, call_method: 'addItem', msg:'item exit'});
                return false;
            }
            self._items.write((caller, item.id), item);
            return true;
        }
        fn updateItem(ref self: ContractState, item: Item) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                self.emit(GameNotExitError{game_address: caller, call_method: 'updateItem'});
                return false;
            }
            if item.id == 0_u256 {
                self.emit(GameItemError{game_address: caller, call_method: 'updateItem', msg:'item.id not 0'});
                return false;
            }
            if self._items.read((caller, item.id)).id == 0_u256{
                self.emit(ItemNotExistError{game_address: caller, call_method: 'updateItem', item_id: item.id, msg:'item not exit, call addItem'});
                return false;
            }
            self._items.write((caller, item.id), item);
            return true;
        }

        // 寄售管理
        // 游戏合约扣除道具后调用. 存储映射：游戏道具映射、个人订单映射
        fn consignment(ref self: ContractState, itemId: u256, amount: u256, price: u256, seller: ContractAddress) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                self.emit(GameNotExitError{game_address: caller, call_method: 'consignment'});
                return false;
            }
            if self._items.read((caller, itemId)).id == 0_u256{
                self.emit(ItemNotExistError{game_address: caller, call_method: 'consignment', item_id: itemId, msg:'item not exit'});
                return false;
            }
            // 创建订单, 保存游戏-订单、玩家-订单映射
            let order_id = self._order_index.read() + 1_u256;
            self._order_index.write(order_id);
            let order = Order{id: order_id, item_id: itemId, owner_addr: seller, amount: amount, leftover: amount, price: price, order_type: 'sell', close: false};
            
            self._sell_orders.write(order_id, order);

            let mut activeOrders = self._user_active_orders.read((caller, seller));
            activeOrders.append(order_id);
            
            let mut orders = self._item_sell_orders.read((caller,itemId));
            orders.append(order_id);
            return true;
        }

        fn buy(ref self: ContractState, buyer: ContractAddress, orderId: u256, amount: u256) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                self.emit(GameNotExitError{game_address: caller, call_method: 'buy'});
                return false;
            }
            let mut order = self._sell_orders.read(orderId);
            if order.id == 0_u256{
                self.emit(OrderNotExistError{game_address: caller,caller: buyer, call_method: 'buy', order_id: orderId, msg:'order not exit'});
                return false;
            }
            if order.close {
                self.emit(OrderError{game_address: caller,caller: buyer, call_method: 'buy', order_id: orderId, msg:'order closed'});
                return false;
            }

            if order.leftover < amount {
                self.emit(OrderError{game_address: caller,caller: buyer, call_method: 'buy', order_id: orderId, msg:'amount overflow order leftover'});
                return false;
            }

            let logId = self._log_index.read() + 1_u256;
            self._log_index.write(logId);
            let log = OrderLog{id:logId, order_id: orderId, op_addr: buyer, amount: amount, price: amount*order.price};
            let mut logs = self._order_logs.read((caller, orderId));
            logs.append(log);
            
            order.leftover = order.leftover - amount;
            // 如果订单结束了，关闭订单。将游戏订单和用户活跃订单的 映射记录删除，添加用户完成订单映射记录
            if order.leftover == 0_u256{
                order.close = true;
                let mut closeOrders = self._user_close_orders.read((caller, order.owner_addr));
                closeOrders.append(orderId);
                let mut activeOrders = self._user_active_orders.read((caller, order.owner_addr));
                let activeArr = activeOrders.array().unwrap();
                let activeIndex = *activeArr.at(orderId.try_into().unwrap());
                activeOrders.set(activeIndex.try_into().unwrap(), activeOrders[0]);
                activeOrders.pop_front();
                let mut orders = self._item_sell_orders.read((caller, order.item_id));
                let orderArr = orders.array().unwrap();
                let orderIndex = *orderArr.at(orderId.try_into().unwrap());
                orders.set(orderIndex.try_into().unwrap(), orders[0]);
                orders.pop_front();
            }

            self._sell_orders.write(orderId, order);
            return true;
        }

        // 道具的在售订单列表
        fn consignmentOrders(self: @ContractState, itemId: u256) -> (Array<Order>,bool){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                return (ArrayTrait::new(),false);
            }
            let orderIds = self._item_sell_orders.read((caller, itemId));
            if orderIds.is_empty(){
                return (ArrayTrait::new(),true);
            }

            let mut orders:Array<Order> = ArrayTrait::new();
            let mut index = 0;
            loop{
                if index >= orderIds.len(){
                    break;
                }
                let orderId = orderIds[index];
                index = index + 1;
                orders.append(self._sell_orders.read(orderId));
            };
            
            return (orders, true);
        }

        // 求购api
        // 创建求购订单和游戏订单映射
        fn wantToBuy(ref self: ContractState, buyer: ContractAddress, itemId: u256, amount: u256, price: u256) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                self.emit(GameNotExitError{game_address: caller, call_method: 'wantToBuy'});
                return false;
            }
            if self._items.read((caller, itemId)).id == 0_u256{
                self.emit(ItemNotExistError{game_address: caller, call_method: 'wantToBuy', item_id: itemId, msg:'item not exit'});
                return false;
            }
            // 创建订单, 保存游戏-订单、玩家-订单映射
            let order_id = self._order_index.read() + 1_u256;
            self._order_index.write(order_id);
            let order = Order{id: order_id, item_id: itemId, owner_addr: buyer, amount: amount, leftover: amount, price: price, order_type: 'buy', close: false};
            
            self._buy_orders.write(order_id, order);

            let mut activeOrders = self._user_active_orders.read((caller, buyer));
            activeOrders.append(order_id);
            
            let mut orders = self._item_buy_orders.read((caller,itemId));
            orders.append(order_id);
            return true;
        }

        fn sell(ref self: ContractState, seller: ContractAddress, orderId: u256, amount: u256) -> bool{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                self.emit(GameNotExitError{game_address: caller, call_method: 'sell'});
                return false;
            }
            let mut order = self._buy_orders.read(orderId);
            if order.id == 0_u256{
                self.emit(OrderNotExistError{game_address: caller,caller: seller, call_method: 'sell', order_id: orderId, msg:'order not exit'});
                return false;
            }
            if order.close {
                self.emit(OrderError{game_address: caller,caller: seller, call_method: 'sell', order_id: orderId, msg:'order closed'});
                return false;
            }

            if order.leftover < amount {
                self.emit(OrderError{game_address: caller,caller: seller, call_method: 'sell', order_id: orderId, msg:'amount overflow order leftover'});
                return false;
            }

            let logId = self._log_index.read() + 1_u256;
            self._log_index.write(logId);
            let log = OrderLog{id:logId, order_id: orderId, op_addr: seller, amount: amount, price: amount*order.price};
            let mut logs = self._order_logs.read((caller, orderId));
            logs.append(log);
            
            order.leftover = order.leftover - amount;
            // 如果订单结束了，关闭订单。将游戏订单和用户活跃订单的 映射记录删除，添加用户完成订单映射记录
            if order.leftover == 0_u256{
                order.close = true;
                let mut closeOrders = self._user_close_orders.read((caller, order.owner_addr));
                closeOrders.append(orderId);
                let mut activeOrders = self._user_active_orders.read((caller, order.owner_addr));
                let activeArr = activeOrders.array().unwrap();
                let activeIndex = *activeArr.at(orderId.try_into().unwrap());
                activeOrders.set(activeIndex.try_into().unwrap(), activeOrders[0]);
                activeOrders.pop_front();
                let mut orders = self._item_buy_orders.read((caller, order.item_id));
                let orderArr = orders.array().unwrap();
                let orderIndex = *orderArr.at(orderId.try_into().unwrap());
                orders.set(orderIndex.try_into().unwrap(), orders[0]);
                orders.pop_front();
            }

            self._buy_orders.write(orderId, order);
            return true;
        }
        fn wantToBuyOrders(self: @ContractState, itemId: u256) -> (Array<Order>,bool){
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                return (ArrayTrait::new(),false);
            }
            let orderIds = self._item_buy_orders.read((caller, itemId));
            if orderIds.is_empty(){
                return (ArrayTrait::new(),true);
            }

            let mut orders:Array<Order> = ArrayTrait::new();
            let mut index = 0;
            loop{
                if index >= orderIds.len(){
                    break;
                }
                let orderId = orderIds[index];
                index = index + 1;
                orders.append(self._buy_orders.read(orderId));
            };
            
            return (orders, true);
        }

        // 个人管理
        fn myActiveOrders(self: @ContractState, person: ContractAddress, op: felt252) -> Array<Order>{
            let caller = get_caller_address();
            if (op != 'sell') && (op != 'buy') && (op != 'auction') {
                return ArrayTrait::new();
            }
            if self._games.read(caller).contract_address.is_zero(){
                return ArrayTrait::new();
            }
            let mut orderIds = self._user_active_orders.read((caller, person));
            
            if orderIds.is_empty(){
                return ArrayTrait::new();
            }

            let mut orders:Array<Order> = ArrayTrait::new();
            let mut index = 0;
            loop{
                if index >= orderIds.len(){
                    break;
                }
                let orderId = orderIds[index];
                index = index + 1;
                if (op == 'buy'){
                    orders.append(self._buy_orders.read(*orderId));
                }else{
                    orders.append(self._sell_orders.read(*orderId));
                }
            };
            
            return orders;
        }

        fn myCloseOrders(self: @ContractState, person: ContractAddress, op: felt252) -> Array<Order>{
            let caller = get_caller_address();
            if (op != 'sell') && (op != 'buy') && (op != 'auction') {
                return ArrayTrait::new();
            }
            if self._games.read(caller).contract_address.is_zero(){
                return ArrayTrait::new();
            }
            let mut orderIds = self._user_close_orders.read((caller, person));
            
            if orderIds.is_empty(){
                return ArrayTrait::new();
            }

            let mut orders:Array<Order> = ArrayTrait::new();
            let mut index = 0;
            loop{
                if index >= orderIds.len(){
                    break;
                }
                let orderId = orderIds[index];
                index = index + 1;

                if (op == 'buy'){
                    orders.append(self._buy_orders.read(*orderId));
                }else{
                    orders.append(self._sell_orders.read(*orderId));
                }
            };
            
            return orders;
        }

        fn orderLogs(self: @ContractState, orderId: u256) -> Array<OrderLog>{
            let caller = get_caller_address();
            if self._games.read(caller).contract_address.is_zero(){
                return ArrayTrait::new();
            }
            return self._order_logs.read((caller, orderId));
        }
    }
}