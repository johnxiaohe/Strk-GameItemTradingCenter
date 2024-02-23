use starknet::ContractAddress;
// 接口定义
#[starknet::interface]
pub trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn totalSupply(self: @TContractState) -> u256;
    fn blanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, to: ContractAddress, amount: u256) -> bool;
    fn transferFrom(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn mint(ref self: TContractState, amount: u256);
}

// 智能合约声明
#[starknet::contract]
pub mod ERC20{
    use core::starknet::event::EventEmitter;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::integer::BoundedInt;

    // 声明hash store宏定义,可以让该结构体作为Map的 key、value使用
    #[derive(Drop, Hash, starknet::Store)]
    struct test{
        name: felt252,
        symbol: felt252
    }

    //存储空间声明
    #[storage]
    struct Storage {
        // 单一存储
        _name: felt252,
        _symbol: felt252,
        _decimals: u8,
        _total_supply: u256,
        // 映射存储
        _balances: LegacyMap::<ContractAddress, u256>,
        _allownces: LegacyMap::<(ContractAddress, ContractAddress), u256>,
        _test: LegacyMap::<test, test>,
    }

    // 事件声明
    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event{
        Transfer: Transfer,
        Approval: Approval,
    }

    // 事件实现
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Transfer{
        // #[key]表示可支持检索的字段
        #[key]
        pub from: ContractAddress,
        #[key]
        pub to: ContractAddress,
        pub value: u256
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct Approval{
        #[key]
        pub owner: ContractAddress,
        #[key]
        pub spender: ContractAddress,
        pub value: u256,
    }

    // 初始化构造方法
    #[constructor]
    fn constructor(ref self: ContractState, name: felt252, symbol: felt252, decimals: u8){
        self._name.write(name);
        self._symbol.write(symbol);
        self._decimals.write(decimals);
    }

    // 合约实现
    #[external(v0)]
    impl ERC20Impl of super::IERC20<ContractState>{

        fn name(self: @ContractState) -> felt252{
            self._name.read()
        }

        fn symbol(self: @ContractState) -> felt252{
            self._symbol.read()
        }

        fn decimals(self: @ContractState) -> u8{
            self._decimals.read()
        }

        fn totalSupply(self: @ContractState) -> u256{
            self._total_supply.read()
        }

        fn blanceOf(self: @ContractState, account: ContractAddress) -> u256{
            self._balances.read(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
            self._allownces.read((owner, spender))
        }

        fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) -> bool{
            let from = get_caller_address();
            self.transfer_helper(from, to, amount);
            true
        }

        fn transferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool{
            let caller = get_caller_address();
            let allowed = self._allownces.read((from, caller));
            if allowed != BoundedInt::max(){
                self._allownces.write((from,caller), allowed - amount);
                self.emit(
                    Event::Approval(Approval{owner: from, spender: caller, value: allowed - amount})
                );
            };

            self.transfer_helper(from, to, amount);
            true
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool{
            let owner = get_caller_address();
            self._allownces.write((owner,spender), amount);
            // 发布事件
            self.emit(Event::Approval(Approval{owner, spender, value: amount}));
            true
        }

        fn mint(ref self: ContractState, amount: u256){
            let caller = get_caller_address();
            self._total_supply.write(self._total_supply.read() + amount);
            self._balances.write(caller, self._balances.read(caller) + amount);
            self.emit(Event::Transfer(Transfer{from: caller, to: caller, value: amount}));

        }
    }

    // 内部方法
    #[generate_trait]
    impl StorageImpl of StorageTrait{
        fn transfer_helper(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256){
                self._balances.write(sender, self._balances.read(sender) - amount);
                self._balances.write(recipient, self._balances.read(recipient) + amount);
                self.emit(Transfer{from: sender, to: recipient, value: amount});
            }
    }

}