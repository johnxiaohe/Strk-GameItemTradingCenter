use tradingcenter::model::{Game,Item,Sell,Buy};

#[starknet::interface]
pub trait IGameItemTradingCenter<TContractState> {
    // 游戏元数据管理
    fn gameSingup(ref self: TContractState, game: Game);
    fn gameUpdate(self: @TContractState);
    fn addItem(self: @TContractState, item: Item);
    fn updateItem(self: @TContractState, item: Item);

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