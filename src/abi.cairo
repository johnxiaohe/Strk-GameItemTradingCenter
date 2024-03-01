use tradingcenter::model::{Game,Item,Order,Buy};

#[starknet::interface]
pub trait IGameItemTradingCenter<TContractState> {
    // 游戏元数据管理
    fn gameSingup(ref self: TContractState, game: Game);
    fn gameUpdate(ref self: TContractState, game: Game);
    fn addItem(ref self: TContractState, item: Item);
    fn updateItem(ref self: TContractState, item: Item);

    // 寄售管理
    fn consignment(ref self: TContractState, itemId: u256, amount: u256, price: u256);
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