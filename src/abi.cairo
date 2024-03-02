use tradingcenter::model::{Game,Item,Order,OrderLog,Buy};
use starknet::ContractAddress;

#[starknet::interface]
pub trait IGameItemTradingCenter<TContractState> {
    // 游戏元数据管理
    fn gameSingup(ref self: TContractState, game: Game) -> bool;
    fn gameUpdate(ref self: TContractState, game: Game) -> bool;
    fn addItem(ref self: TContractState, item: Item) -> bool;
    fn updateItem(ref self: TContractState, item: Item) -> bool;

    // 寄售管理
    fn consignment(ref self: TContractState, itemId: u256, amount: u256, price: u256, seller: ContractAddress) -> bool;
    fn buy(ref self: TContractState, buyer: ContractAddress, orderId: u256, amount: u256) -> bool;
    fn consignmentOrders(self: @TContractState, itemId: u256) -> (Array<Order>,bool);
    
    // 求购管理
    fn wantToBuy(ref self: TContractState, buyer: ContractAddress, itemId: u256, amount: u256, price: u256) -> bool;
    fn sell(ref self: TContractState, seller: ContractAddress, orderId: u256, amount: u256) -> bool;
    fn wantToBuyOrders(self: @TContractState, itemId: u256) -> (Array<Order>,bool);

    // 个人管理
    fn myActiveOrders(self: @TContractState, person: ContractAddress, op: felt252) -> Array<Order>;
    fn myCloseOrders(self: @TContractState, person: ContractAddress, op: felt252) -> Array<Order>;
    fn orderLogs(self: @TContractState, orderId: u256) -> Array<OrderLog>;
}